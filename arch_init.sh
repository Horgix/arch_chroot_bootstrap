#! /bin/bash

pacman-key  --init
pacman-key  --populate archlinux
pacman      -Syu  --noconfirm
pacman      -S    --noconfirm base btrfs-progs vim

swapoff -a
sync

# Btrfs prep

## Create subvolumes
mkfs.btrfs -f /dev/sda
mount -t btrfs /dev/sda /mnt
for subvol in boot root home roothome var; do
  btrfs subvolume create /mnt/subvol_$subvol
done
umount /mnt

## Mount subvolumes
mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
for subvol in boot home var; do
  mkdir /mnt/$subvol
  mount -t btrfs -o subvol=subvol_$subvol /dev/sda /mnt/$subvol
done
mkdir /mnt/root
mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root

# Base setup
pacstrap /mnt base base-devel python python2 btrfs-progs openssh grub intel-ucode sudo
#genfstab -U /mnt >> /mnt/etc/fstab

# And let's finally prepare it to a fully working installation :)
curl -o /mnt/arch_prepare.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_prepare.sh
chmod +x /mnt/arch_prepare.sh

if [ ! -z $1 ]; then
  echo 'Found hostname, passing it'
  arch-chroot /mnt ./arch_prepare.sh $1
else
  arch-chroot /mnt ./arch_prepare.sh
fi

umount -R /mnt

# In case you want to mount everything like previously but by hand...
# mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
# mount -t btrfs -o subvol=subvol_home /dev/sda /mnt/home
# mount -t btrfs -o subvol=subvol_boot /dev/sda /mnt/boot
# mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root
# mount -t btrfs -o subvol=subvol_var /dev/sda /mnt/var
