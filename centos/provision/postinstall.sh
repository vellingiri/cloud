#/bin/bash

set -x

#systemctl stop iptables
#systemctl disable iptables
#
#mv /root/keystonerc_admin /etc
#source /etc/keystonerc_admin
#echo 'source /etc/keystonerc_admin' >> /root/.bashrc

neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external
neutron subnet-create --name public_subnet --enable_dhcp=False --allocation-pool=start=192.168.2.10,end=192.168.2.250 --gateway=192.168.2.1 external_network 192.168.2.0/24
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance image-create --name='cirros' --visibility=public --container-format=bare --disk-format=qcow2
neutron router-create router1
neutron router-gateway-set router1 external_network
neutron net-create private_network
neutron subnet-create --name private_subnet private_network 10.0.0.1/24
neutron router-interface-add router1 private_subnet

