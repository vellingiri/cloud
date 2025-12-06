#!/bin/bash
set -e

###############################################################################
# CONFIGURATION
###############################################################################
RELEASE="jammy"            # Ubuntu 22.04
ARCH="amd64"
IMAGE_NAME="ubuntu-22.04"
IMAGE_SIZE="4G"            # 4GB to avoid dpkg unpack errors

WORKDIR="${PWD}/${IMAGE_NAME}"
ROOTFS="${WORKDIR}/rootfs"
DISK="${WORKDIR}/${IMAGE_NAME}.img"
QCOW="${WORKDIR}/${IMAGE_NAME}.qcow2"

###############################################################################
# PREPARE ENVIRONMENT
###############################################################################
echo "[1] Installing required host packages..."
apt-get update -y
apt-get install -y \
  debootstrap \
  qemu-utils \
  grub-pc-bin \
  cloud-init \
  initramfs-tools \
  udev \
  linux-image-virtual \
  dosfstools \
  gdisk

mkdir -p "${ROOTFS}" "${WORKDIR}"

###############################################################################
# STEP 1 — CREATE BASE ROOTFS
###############################################################################
echo "[2] Running debootstrap (no GPG check)..."
debootstrap \
  --no-check-gpg \
  --arch=${ARCH} \
  ${RELEASE} \
  "${ROOTFS}" \
  http://192.168.2.134/ubuntu/

###############################################################################
# STEP 2 — CREATE EMPTY RAW DISK
###############################################################################
echo "[3] Creating raw disk image..."
dd if=/dev/zero of="${DISK}" bs=1 count=0 seek=${IMAGE_SIZE}

###############################################################################
# STEP 3 — PARTITION DISK
###############################################################################
echo "[4] Partitioning disk..."
parted -s "${DISK}" mklabel msdos
parted -s "${DISK}" mkpart primary ext4 1MiB 100%

###############################################################################
# STEP 4 — SETUP LOOP DEVICE
###############################################################################
LOOP=$(losetup --show -f -P "${DISK}")
echo "Loop device used: ${LOOP}"

###############################################################################
# STEP 5 — FORMAT ROOT PARTITION
###############################################################################
echo "[5] Formatting root filesystem..."
mkfs.ext4 "${LOOP}p1"

###############################################################################
# STEP 6 — MOUNT AND POPULATE ROOTFS
###############################################################################
echo "[6] Mounting disk..."
mkdir -p "${WORKDIR}/mnt"
mount "${LOOP}p1" "${WORKDIR}/mnt"

echo "[7] Copying root filesystem..."
cp -a "${ROOTFS}/." "${WORKDIR}/mnt/"

###############################################################################
# STEP 7 — SYSTEM CONFIG (fstab + hostname)
###############################################################################
echo "[8] Writing fstab..."
echo "/dev/sda1 / ext4 defaults 0 1" > "${WORKDIR}/mnt/etc/fstab"

echo "[9] Setting hostname..."
echo "ubuntu" > "${WORKDIR}/mnt/etc/hostname"

###############################################################################
# STEP 8 — BIND MOUNT SYSTEM DIRECTORIES FOR CHROOT
###############################################################################
echo "[10] Bind mounting /dev /proc /sys /run..."
mount --bind /dev  "${WORKDIR}/mnt/dev"
mount --bind /proc "${WORKDIR}/mnt/proc"
mount --bind /sys  "${WORKDIR}/mnt/sys"
mount --bind /run  "${WORKDIR}/mnt/run"

###############################################################################
# STEP 9 — INSTALL BOOTLOADER, KERNEL, CLOUD-INIT
###############################################################################
echo "[11] Installing system packages inside chroot..."
chroot "${WORKDIR}/mnt" bash -c "
  set -e
  export DEBIAN_FRONTEND=noninteractive
  
  apt-get update -y

  # REQUIRED for kernel + initramfs
  apt-get install -y udev initramfs-tools

  # LIGHTWEIGHT kernel (no extra-large modules)
  apt-get install -y linux-image-virtual

  # SSH server
  apt-get install -y openssh-server
  systemctl enable ssh

  # CLOUD-INIT SUPPORT
  apt-get install -y cloud-init cloud-initramfs-growroot

  # GRUB BOOTLOADER
  apt-get install -y grub-pc grub-pc-bin

  apt-get clean
  echo "deb http://192.168.2.134/ubuntu jammy-security jammy jammy-proposed jammy-updates jammy-backports"
"


cat > "${WORKDIR}/mnt/etc/cloud/cloud.cfg.d/90-disable-openstack-users.cfg" << 'EOF'
# Disable OpenStack datasource user + ssh management
datasource:
  OpenStack:
    apply_network_config: False
    manage_resolve_conf: False
    user_data: ""
    vendor_data: ""
    admin_pass: ""
    password: ""
    metadata_urls: []
    max_wait: 0

users: []
disable_root: false
ssh_pwauth: true
EOF


cat > "${WORKDIR}/mnt/etc/cloud/cloud.cfg.d/99-override-users.cfg" << 'EOF'
system_info:
  default_user:
    name: ubuntu
    lock_passwd: false
    gecos: Ubuntu
    groups: [adm, sudo]
    shell: /bin/bash

ssh_pwauth: true
disable_root: false

chpasswd:
  expire: False
EOF

rm -rf "${WORKDIR}/mnt/var/lib/cloud/*"
chroot "${WORKDIR}/mnt" cloud-init clean

chroot "${WORKDIR}/mnt" passwd -u root

echo "root:master"   | chroot "${WORKDIR}/mnt" chpasswd

chroot "${WORKDIR}/mnt" bash -c "
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    "

###############################################################################
# STEP 10 — INSTALL GRUB INTO DISK IMAGE
###############################################################################
echo "[12] Installing GRUB bootloader..."
echo 'GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0"' >> "${WORKDIR}/mnt/etc/default/grub"
echo 'GRUB_TERMINAL="console serial"' >> "${WORKDIR}/mnt/etc/default/grub"
echo 'GRUB_SERIAL_COMMAND="serial --speed=115200"' >> "${WORKDIR}/mnt/etc/default/grub"

chroot "${WORKDIR}/mnt" grub-install --target=i386-pc --recheck "${LOOP}"

echo "[13] Updating GRUB config..."
chroot "${WORKDIR}/mnt" update-grub || true

###############################################################################
# STEP 11 — CLEANUP
###############################################################################
echo "[14] Cleaning up mounts..."
umount "${WORKDIR}/mnt/dev" || true
umount "${WORKDIR}/mnt/proc" || true
umount "${WORKDIR}/mnt/sys" || true
umount "${WORKDIR}/mnt/run" || true
umount "${WORKDIR}/mnt"

losetup -d "${LOOP}"

###############################################################################
# STEP 12 — CONVERT RAW → QCOW2
###############################################################################
echo "[15] Creating QCOW2 image..."
qemu-img convert -O qcow2 "${DISK}" "${QCOW}"

echo
echo "=============================================================="
echo "✔ IMAGE BUILD COMPLETE (v5)"
echo "RAW IMAGE : ${DISK}"
echo "QCOW2     : ${QCOW}"
echo "SIZE      : $(du -h "${QCOW}" | cut -f1)"
echo "=============================================================="
echo
echo "Upload to OpenStack:"
echo "  openstack image create --disk-format qcow2 --container-format bare --file ${QCOW} ubuntu2204"
echo
