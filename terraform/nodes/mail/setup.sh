#!/bin/bash
touch /root/.hushlogin
echo -e "search rdulinux.com\nnameserver 192.168.2.3" >/etc/resolv.conf
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
rm -fv /root/.ssh/authorized_keys
systemctl restart sshd
echo -e 'master\nmaster' | passwd root
apt-get update
apt-get install wget vim netcat wget net-tools lsof nfs-common -y
cd /tmp
wget https://apt.puppetlabs.com/puppet8-release-jammy.deb
dpkg -i puppet8-release-jammy.deb
apt update
apt install puppet-agent -y
echo -e "[main]\ncertname = `hostname -f`\nserver = puppet" > /etc/puppetlabs/puppet/puppet.conf
systemctl start puppet
systemctl enable puppet
systemctl status puppet
/opt/puppetlabs/bin/puppet agent -tv
