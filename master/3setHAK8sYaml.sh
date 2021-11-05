#!/bin/bash
# Program:
#       1.Set haproxy keepalived kubeadm-config yaml and haproxy cfg
# History:
# 2021/07/28    Mark_Chen       First release

# Set kubeadm kubelet kubectl versions and other parameters
kubeVer="1.19.0"
apiserver1="10.0.2.15"
apiserver2="10.0.2.16"
apiserver3="10.0.2.17"
vip="10.0.2.200"
networkInterface="vlan.206"
keepalivedPriority="150"
podCIDR="10.244.0.0/16"
serviceCIDR="10.96.0.0/12"

# Set haproxy keepalived kubeadm-config yaml and haproxy cfg
mkdir -p /etc/kubernetes/manifests/

# Set up HAProxy
mkdir -p /etc/haproxy/

cat <<EOF > /etc/haproxy/haproxy.cfg
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  tune.ssl.default-dh-param 2048

defaults
  log global
  mode http
  option dontlognull
  timeout connect 5000ms
  timeout client 600000ms
  timeout server 600000ms

listen stats
    bind :8090
    mode http
    balance
    stats uri /haproxy_stats
    stats auth admin:admin123
    stats admin if TRUE

frontend kube-apiserver-https
   mode tcp
   bind :8443
   default_backend kube-apiserver-backend

backend kube-apiserver-backend
    mode tcp
    balance roundrobin
    stick-table type ip size 200k expire 30m
    stick on src
    server apiserver1 $apiserver1:6443  check
    server apiserver2 $apiserver2:6443  check
    server apiserver3 $apiserver3:6443  check
EOF

# Create haproxy.yaml
cat <<EOF > /etc/kubernetes/manifests/haproxy.yaml
kind: Pod
apiVersion: v1
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    component: haproxy
    tier: control-plane
  name: kube-haproxy
  namespace: kube-system
spec:
  hostNetwork: true
  priorityClassName: system-cluster-critical
  containers:
  - name: kube-haproxy
    image: docker.io/haproxy:2.3.2-alpine
    resources:
      requests:
        cpu: 100m
    volumeMounts:
    - name: haproxy-cfg
      readOnly: true
      mountPath: /usr/local/etc/haproxy/haproxy.cfg
  volumes:
  - name: haproxy-cfg
    hostPath:
      path: /etc/haproxy/haproxy.cfg
      type: FileOrCreate
EOF

# Set up Keepalived
cat <<EOF > /etc/kubernetes/manifests/keepalived.yaml
kind: Pod
apiVersion: v1
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  labels:
    component: keepalived
    tier: control-plane
  name: kube-keepalived
  namespace: kube-system
spec:
  hostNetwork: true
  priorityClassName: system-cluster-critical
  containers:
  - name: kube-keepalived
    image: docker.io/osixia/keepalived:2.0.20
    env:
    - name: KEEPALIVED_VIRTUAL_IPS
      value: $vip
    - name: KEEPALIVED_INTERFACE
      value: $networkInterface
    - name: KEEPALIVED_UNICAST_PEERS
      value: "#PYTHON2BASH:['$apiserver1', '$apiserver2', '$apiserver3']"
    - name: KEEPALIVED_PASSWORD
      value: d0cker
    - name: KEEPALIVED_PRIORITY
      value: "$keepalivedPriority"
    - name: KEEPALIVED_ROUTER_ID
      value: "51"
    resources:
      requests:
        cpu: 100m
    securityContext:
      privileged: true
      capabilities:
        add:
        - NET_ADMIN
EOF

# Set up kubeadm-config.yaml
cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  extraArgs:
    advertise-address: $apiserver1
    authorization-mode: Node,RBAC
controlPlaneEndpoint: $vip:8443
imageRepository: k8s.gcr.io
kubernetesVersion: v$kubeVer
networking:
  dnsDomain: cluster.local
  podSubnet: $podCIDR
  serviceSubnet: $serviceCIDR
EOF

exit 0
