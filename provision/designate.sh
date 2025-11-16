#/bin/bash

set -x

#fixing mirror
#sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*
#sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*

openstack user create --domain default --project services --password designate designate
openstack role add --project services --user designate admin
openstack service create --name designate --description "OpenStack DNS Service" dns

export designate_api=192.168.2.2
openstack endpoint create --region RegionOne dns public http://$designate_api:9001/
openstack endpoint create --region RegionOne dns internal http://$designate_api:9001/
openstack endpoint create --region RegionOne dns admin http://$designate_api:9001/

mysql -u root -e "create database designate;"
mysql -u root -e "grant all privileges on designate.* to designate@'openstack' identified by 'designate';"
mysql -u root -e "grant all privileges on designate.* to designate@'%' identified by 'designate';"
mysql -u root -e "flush privileges;"


dnf --enablerepo=centos-openstack-yoga -y install openstack-designate-api openstack-designate-central openstack-designate-worker openstack-designate-producer openstack-designate-mdns python3-designateclient bind bind-utils

rndc-confgen -a -k designate -c /etc/designate.key -r /dev/urandom
chown named:designate /etc/designate.key
chmod 640 /etc/designate.key
mv /etc/named.conf /etc/named.conf.org
cp /share/config/named/named.conf /etc/named.conf
chmod 640 /etc/named.conf
chgrp named /etc/named.conf
chown -R named. /var/named
systemctl enable --now named

mv /etc/designate/designate.conf /etc/designate/designate.conf.org
cp /share/config/designate/designate.conf /etc/designate/designate.conf
chmod 640 /etc/designate/designate.conf
chgrp designate /etc/designate/designate.conf
su -s /bin/bash -c "designate-manage database sync" designate
systemctl enable --now designate-central designate-api

cp /share/config/designate/pools.yaml /etc/designate/pools.yaml
chmod 640 /etc/designate/pools.yaml
chgrp designate /etc/designate/pools.yaml
su -s /bin/bash -c "designate-manage pool update" designate
systemctl enable --now designate-worker designate-producer designate-mdns

openstack dns service list

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform

cd /share/cloud/terraform/dns
terraform init
terraform validate
terraform apply -auto-approve


#echo -e 'search rdulinux.com\nnameserver 192.168.2.2' > /etc/resolv.conf
