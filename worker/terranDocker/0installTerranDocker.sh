#!/bin/bash
# Program:
#       1.Install Terran Docker
# History:
# 2021/0802    Mark_Chen       First release

# Set docker and containerd versions
dockerCeVer="docker-ce_19.03.15~terran~3-0~ubuntu-focal_amd64"
dockerCliVer="docker-ce-cli_19.03.15~terran~3-0~ubuntu-focal_amd64"
# containerdVer="containerd.io_1.4.3-1_amd64"

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
sudo apt-get -y install containerd.io=1.4.3-1
sudo dpkg -i $dockerCliVer.deb
sudo dpkg -i $dockerCeVer.deb
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
