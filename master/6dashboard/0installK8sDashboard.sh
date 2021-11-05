#!/bin/bash
# Program:
#       1.Install Kubernetes Dashboard and create login token
# History:
# 2021/07/29    Mark_Chen       First release

# Generate self-signed certificates
mkdir /root/certs
openssl req -nodes -newkey rsa:2048 -keyout /root/certs/dashboard.key -out /root/certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in /root/certs/dashboard.csr -signkey /root/certs/dashboard.key -out /root/certs/dashboard.crt

# Generate the kubernetes-dashboard-certs certificate file
kubectl create ns kubernetes-dashboard
kubectl create secret generic kubernetes-dashboard-certs --from-file=/root/certs -n kubernetes-dashboard

# Install kubernetes-dashboard
kubectl create -f k8s-dashboard.yaml
kubectl create -f k8s-dashboard-svc.yaml

# Get a Bearer Token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') >> k8sDashboardToken

exit 0
