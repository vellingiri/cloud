#!/bin/bash
set -xe

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
echo "ubuntu:master" | sudo chpasswd
echo "root:master" | sudo chpasswd
