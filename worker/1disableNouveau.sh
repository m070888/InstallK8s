#!/bin/bash
# Program:
#       1.Disable nouveau due to install GPU driver
# History:
# 2021/07/29    Mark_Chen       First release

# Install GPU Driver need to Disable nouveau
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
lsmod  | grep nouveau
sudo shutdown -r now

exit 0
