#!/usr/bin/env bash

# Pacman
pacman -Sy archlinux-keyring --noconfirm > /dev/null
pacman-key --init
# pacman -Scc

# See Drives
lsblk

# Drive Selection
read -p "[Select Drive]: " sysdrive

# Partitioning
wipefs --all $sysdrive
(
  echo g;
  echo n;
  echo ;
  echo ;
  echo +512M; # EFI (512MiB)
  echo n;
  echo ;
  echo ;
  echo ; # PRIMARY (Remaining Space)
  echo t;
  echo 1;
  echo 1;
  echo t;
  echo ;
  echo 19;
  echo w;
) | fdisk $sysdrive

# Format EFI
mkfs.vfat -F32 -n EFI $sysdrive"1"

# Setup Encrypted LUKS
cryptsetup --use-random luksFormat $sysdrive"2"
cryptsetup luksOpen $sysdrive"2" luks

# Setup LVM
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 4G vg0 --name swap # 4GB SWAP
lvcreate -l +100%FREE vg0 --name root # Remaining -> Primary

# Format LVM
mkfs.ext4 -L root /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap
swapon /dev/mapper/vg0-swap

# Mount System
mount /dev/mapper/vg0-root /mnt
mount --mkdir $sysdrive"1" /mnt/boot 

# Prepare Base System
pacstrap /mnt base base-devel linux linux-firmware sudo efibootmgr lvm2 dialog wpa_supplicant nano vim git dhclient
genfstab -pU /mnt | tee -a /mnt/etc/fstab
git clone https://github.com/archungus333/archinstall.git /mnt/root/archinstall
arch-chroot /mnt
