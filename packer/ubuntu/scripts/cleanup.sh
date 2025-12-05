#!/bin/bash
set -xe

sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/apt/archives/*
sudo rm -rf /var/log/*

sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY
sync
