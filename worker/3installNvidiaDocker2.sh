#!/bin/bash
# Program:
#       1.Install nvidia-docker2
# History:
# 2021/07/29    Mark_Chen       First release

# Setup the stable repository and the GPG key
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   
# Install nvidia-docker2
sudo apt-get update
sudo apt-get install -y nvidia-docker2

# Set the default runtime
sudo mkdir -p /etc/docker/
rm -rf /etc/docker/daemon.json
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "default-runtime": "nvidia",
  "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF

# Restart the Docker daemon to complete the installation
sudo systemctl daemon-reload
sudo systemctl restart docker

# Test by running a base CUDA container
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

exit 0
