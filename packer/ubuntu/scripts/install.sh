#!/bin/bash
set -xe

UBUNTU_HASH="$6$cGXurTB6qymvyTNi$ClVXJcZAJE3E1dmFlHZJF6.BvKbh7IedU4TiOxC6naF3t4cd1Xw3OhOocICY7W01o7589thEX1Sdi1jEt3WKM0"

sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo rm -fv /root/.ssh/authorized_keys
sudo touch /home/ubuntu/.hushlogin /root/.hushlogin
echo "root:master" | sudo chpasswd
sudo usermod -p "${UBUNTU_HASH}" ubuntu
sudo passwd -u ubuntu
echo "ubuntu:master" | sudo chpasswd
