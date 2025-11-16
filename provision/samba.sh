#/bin/bash
#https://stackoverflow.com/questions/12009/piping-password-to-smbpasswd
#https://www.rootusers.com/how-to-clear-the-sssd-cache-in-linux/

set -x

PASS='master'
LOGIN='centos'

dnf -y install samba
groupadd smbgroup
chgrp smbgroup /share
chmod 770 /share
cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp
cp /share/config/samba/smb.conf /etc/samba/smb.conf

systemctl enable --now smb

echo -ne "$PASS\n$PASS\n" | smbpasswd -a -s $LOGIN

usermod -aG smbgroup centos
