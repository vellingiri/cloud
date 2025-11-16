#/bin/bash

set -x

INTERFACE="ifcfg-eth0"

sed -i 's/GRUB_CMDLINE_LINUX="rhgb quiet"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 intel_iommu=on"/g' /etc/default/grub

rpm -qa | grep kernel | egrep -i '(408|474)' | xargs dnf remove -y

grub2-mkconfig -o /boot/grub2/grub.cfg

mv /etc/sysconfig/network-scripts/ifcfg-enp3s0 /etc/sysconfig/network-scripts/$INTERFACE

sed -i 's/NAME=enp3s0/NAME=eth0/' /etc/sysconfig/network-scripts/$INTERFACE
sed -i 's/DEVICE=enp3s0/DEVICE=eth0/' /etc/sysconfig/network-scripts/$INTERFACE


systemctl reboot
