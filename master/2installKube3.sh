#!/bin/bash
# Program:
#       1.Set up HA Kubernetes Master
# History:
# 2021/07/28    Mark_Chen       First release

# Set kubeadm kubelet kubectl versions and other parameters
kubeVer="1.19.0"
kubeVerForInstall="$kubeVer-00"

# Update the apt package
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=$kubeVerForInstall kubeadm=$kubeVerForInstall kubectl=$kubeVerForInstall
sudo apt-mark hold kubelet kubeadm kubectl

exit 0
