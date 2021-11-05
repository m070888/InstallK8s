#!/bin/bash
# Program:
#       1.Initialize the control plane
# History:
# 2021/07/28    Mark_Chen       First release

# Initialize the control plane through kubeadm
kubeadm init --config=kubeadm-config.yaml --upload-certs

# Run the following to make kubectl work for your non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

exit 0
