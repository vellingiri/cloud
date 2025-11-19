#/bin/bash

set -x

touch /root/.hushlogin

rm -rf /root/*

echo -e 'nameserver 192.168.2.1' > /etc/resolv.conf

#add locale environments
echo -e 'LANG=en_US.utf-8\nLC_ALL=en_US.utf-8' > /etc/environment

#fixing mirror
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*


#disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/sysconfig/selinux /etc/selinux/config
sed -i 's/SELINUXTYPE=targeted/#SELINUXTYPE=targeted/g' /etc/sysconfig/selinux /etc/selinux/config

dnf update -y

systemctl reboot
