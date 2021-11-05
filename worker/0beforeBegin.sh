#!/bin/bash
# Program:
#       1.Letting iptables see bridged traffic
#       2.Disable SWAP
# History:
# 2021/07/28    Mark_Chen       First release

# Letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

# Disable SWAP
sudo swapoff -a && sysctl -w vm.swappiness=0
sed '/swap/d' -i /etc/fstab

exit 0
