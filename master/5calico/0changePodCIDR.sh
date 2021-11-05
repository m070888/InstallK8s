#!/bin/bash
# Program:
#       1.Change Pod CIDR in calico.yaml
# History:
# 2021/07/28    Mark_Chen       First release

# Set Pod CIDR，default: 10.244.0.0/16
podCIDR="10.244.0.0\/16"

sed -i 's/10.244.0.0\/16/'"$podCIDR"'/g' calico.yaml

exit 0
