#/bin/bash

set -x

#updating hostname
#echo -e '192.168.2.5	cloud	cloud.rdulinux.com' > /etc/hosts

#fixing mirror
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*

dnf update -y
dnf config-manager --enable powertools
dnf install -y centos-release-openstack-yoga

#fixing mirror
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*

dnf update -y
dnf install -y openstack-packstack


dnf install network-scripts -y
systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

systemctl reboot
#packstack --allinone --os-cinder-install=n --os-swift-install=n --os-ceilometer-install=n --os-neutron-l2-agent=openvswitch --os-neutron-ml2-mechanism-drivers=openvswitch --os-neutron-ml2-tenant-network-types=vxlan --os-neutron-ml2-type-drivers=vxlan,flat,vlan --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex --os-neutron-ovs-bridge-interfaces=br-ex:eth0
