#!/bin/bash
# Program:
#       1.Install Docker Engine
# History:
# 2021/07/28    Mark_Chen       First release

# Set docker and containerd versions
dockerVer="5:19.03.15~3-0~ubuntu-focal"
containerdVer="1.4.3-1"

# Uninstall old versions
sudo apt-get -y remove docker docker-engine docker.io containerd runc

sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get -y install docker-ce=$dockerVer docker-ce-cli=$dockerVer containerd.io=$containerdVer
sudo apt-mark hold docker-ce docker-ce-cli containerd.io

# Configure cgroup driver to use systemd
sudo mkdir -p /etc/docker/
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# Start and enable docker engine
sudo systemctl enable docker 
sudo systemctl daemon-reload
sudo systemctl restart docker

exit 0
