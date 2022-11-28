#!/usr/bin/env bash

# Set Hostname 
read -p "[Enter Hostname]: " hostname
echo $hostname > /etc/hostname

# Change Root Passwd
echo "[Enter Root Passwd]"
passwd

# Setup User
read -p "[Enter Username]: " username
useradd -mG wheel $username
echo "[Enter Username Passwd]"
passwd $username
export EDITOR=nano
sed --in-place=.bak 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Sys Clock
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Locale
sed --in-place=.bak 's/^#de_DE\.UTF-8/de_DE\.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=de_DE.UTF-8 > /etc/locale.conf
echo LC_ALL= >> /etc/locale.conf

# Vconsole
echo "KEYMAP=de-latin1-nodeadkeys" > /etc/vconsole.conf

# Hosts file
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts

# Pacman
pacman -Syyu
pacman --noconfirm -S networkmanager iwd wireless_tools mtools reflector linux-headers xdg-utils xdg-user-dirs 

# Mkinitcpio Config
sed --in-place=.bak 's/^MODULES=()/MODULES=(ext4)/' /etc/mkinitcpio.conf
sed --in-place=.bak 's/^HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Systembootd Setup
bootctl --path=/boot install
echo default arch >> /boot/loader/loader.conf
echo timeout 5 >> /boot/loader/loader.conf
# blkid -s UUID -o value /dev/sda2 > uuid.tmp
blkid -s PARTUUID -o value /dev/sda2 > /tmp/partuuid.tmp
partuuid=$(</tmp/partuuid.tmp)
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
# echo "options cryptdevice=UUID=$uuid:vg0 root=/dev/mapper/vg0-root" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=PARTUUID=$partuuid:vg0 root=/dev/mapper/vg0-root" >> /boot/loader/entries/arch.conf

# Systemd
systemctl disable NetworkManager
systemctl enable iwd

# Blacklist Dell Error
echo "blacklist dell_laptop" > /etc/modprobe.d/blacklist.conf

# Get Dots
# git clone https://github.com/archungus333/dots.git /home/$username
