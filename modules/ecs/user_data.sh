#!/bin/bash

# Allocate a swap file (2 GB)
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
fi

# Enable the swap file
swapon /swapfile

# Add to /etc/fstab for persistence
if ! grep -q '/swapfile' /etc/fstab; then
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

# Set swappiness (Optional)
sysctl -w vm.swappiness=10
if ! grep -q 'vm.swappiness' /etc/sysctl.conf; then
  echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

swapon --show
free -h

## Configure cluster name using the template variable ${ecs_cluster_name}
echo ECS_CLUSTER='${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file", "awslogs"]' >> /etc/ecs/ecs.config