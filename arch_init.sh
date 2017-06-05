#! /bin/bash

pacman-key  --init
pacman-key  --populate archlinux
pacman  -Syu  --noconfirm
pacman  -S    --noconfirm base btrfs-progs vim

swapoff -a
sync
mkfs.btrfs -f /dev/sda
mount -t btrfs /dev/sda /mnt
for subvol in boot root home roothome var; do
  btrfs subvolume create /btrfs/subvol_$subvol
done
umount /mnt

mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
for subvol in boot home var; do
  mount -t btrfs -o subvol=subvol_$subvol /dev/sda /mnt/$subvol
done
mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root

pacstrap /mnt base base-devel python python2 btrfs-progs openssh grub intel-ucode

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
sed -i 's/#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo KEYMAP=us > /etc/vconsole.conf

cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/dhcp
sed -i 's/eth0/eno1/' /etc/netctl/dhcp
netctl enable dhcp


useradd -m horgix



systemctl enable netctl
systemctl enable sshd
systemctl enable getty@tty1.service

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

passwd root
passwd horgix


#mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
#mount -t btrfs -o subvol=subvol_home /dev/sda /mnt/home
#mount -t btrfs -o subvol=subvol_boot /dev/sda /mnt/boot
#mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root
#mount -t btrfs -o subvol=subvol_var /dev/sda /mnt/var
