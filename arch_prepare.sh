#! /bin/bash

ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo KEYMAP=us > /etc/vconsole.conf

cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/dhcp
sed -i 's/eth0/eno1/' /etc/netctl/dhcp
netctl enable dhcp


useradd -m horgix -G wheel
sed -i 's/# \(%wheel ALL=(ALL) ALL\)/\1/' /etc/sudoers



systemctl enable netctl
systemctl enable sshd
systemctl enable getty@tty1.service

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

if [ ! -z $1 ]; then
  echo 'Setting hostname'
  hostname $1
fi


passwd root
passwd horgix

