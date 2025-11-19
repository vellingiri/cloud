#!/bin/bash

# Detects the OS
detect_os() {
    if grep -q -i ubuntu /etc/os-release; then
        OS="ubuntu"
    elif grep -q -i centos /etc/os-release; then
        OS="centos"
    else
        echo "Unsupported OS. This script supports only Ubuntu and CentOS."
        exit 1
    fi
}

# Updates package lists and installs common packages
update_and_install_common() {
    echo "Updating package lists and installing common packages..."
    touch /root/.hushlogin
    echo -e "search rdulinux.com\nnameserver 192.168.2.3" > /etc/resolv.conf
    echo -e 'master\nmaster' | passwd root

    case "$OS" in
        ubuntu)
            apt-get update
            apt-get install -y wget vim netcat net-tools lsof nfs-common
            sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
            sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
            rm -fv /root/.ssh/authorized_keys
            systemctl restart sshd
            ;;
        centos)
	    #cd /etc/yum.repos.d/ ; rm -rfv *
	    #curl http://repo.rdulinux.com/centos/8/x86_64/centos.repo -o centos.repo
            #dnf update -y
            dnf install -y curl wget vim
            sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
            sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
            rm -fv /root/.ssh/authorized_keys
            systemctl restart sshd
            ;;
    esac
}

# Sets up Puppet client
setup_puppet() {
    echo "Setting up a Puppet client..."

    case "$OS" in
        ubuntu)
            cd /tmp
            wget https://apt.puppetlabs.com/puppet8-release-jammy.deb
            dpkg -i puppet8-release-jammy.deb
            apt update
            apt install -y puppet-agent
            echo -e "[main]\ncertname = $(hostname -f)\nserver = puppet" > /etc/puppetlabs/puppet/puppet.conf
            systemctl start puppet
            systemctl enable puppet
            systemctl status puppet
            /opt/puppetlabs/bin/puppet agent -tv
            ;;
        centos)
            echo "Puppet setup for CentOS is not yet implemented."
            # Uncomment and complete if needed
            # dnf update -y
            # dnf install puppet -y
            echo -e "[main]\ncertname = $(hostname -f)\nserver = puppet" > /etc/puppetlabs/puppet/puppet.conf
            ;;
    esac
}

# Main execution
detect_os
update_and_install_common
setup_puppet

echo "Post-installation script completed."
