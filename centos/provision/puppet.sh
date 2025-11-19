#/bin/bash

set -x

#dnf -y install https://yum.puppet.com/puppet-release-el-9.noarch.rpm
#dnf -y install puppetserver

config=$(
cat <<'EOF'
[server]
vardir = /opt/puppetlabs/server/data/puppetserver
logdir = /var/log/puppetlabs/puppetserver
rundir = /var/run/puppetlabs/puppetserver
pidfile = /var/run/puppetlabs/puppetserver/puppetserver.pid
codedir = /etc/puppetlabs/code

confdir = /etc/puppetlabs/puppet
dns_alt_names = puppetmaster.rdulinux.com
# any [environment] name
environment = production


[main]
certname = puppetmaster.rdulinux.com
server = puppetmaster.rdulinux.com

[agent]
server = puppetmaster.rdulinux.com
ca_server = puppetmaster.rdulinux.com
# interval for applying catalogs on server
# if set [0], always applied
# default is 30 minutes if the value is not set
runinterval = 30m
EOF
)


systemctl enable --now puppetserver

puppet module install saz-resolv_conf


#site.pp

package { ['nc', 'vim', 'lsof']:
  provider => yum,
  ensure   => installed,
}

class { 'resolv_conf':
    nameservers => ['192.168.2.5'],
    domainname  => 'rdulinux.com',
}
