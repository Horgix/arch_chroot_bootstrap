#! /bin/bash

fail()
{
  tput bold
  tput setaf 1
  if [ "$1" == "IGNORE" ]; then
    echo "Something went wrong, stopping."
    tput sgr0
    exit 1
  else
    echo "Something went wrong, but ignoring."
    tput sgr0
  fi
}

error() {   tput setaf 1; echo -n "[ FAIL ] "; tput sgr0; echo "$@"; fail; }
success() { tput setaf 2; echo -n "[  OK  ] "; tput sgr0; echo "$@"; }
info() {    tput setaf 3; echo -n "[ INFO ] "; tput sgr0; echo "$@"; }
header() {  tput setaf 3; echo -n "[ INFO ] "; echo "===== $@ ====="; tput sgr0; }

header "Preparing temporary arch with needed tools"
pacman-key  --init
pacman-key  --populate archlinux
pacman      -Syu  --noconfirm
pacman      -S    --noconfirm base btrfs-progs vim

swapoff -a
sync

header "Setting up btrfs"

info "Creating subvolumes..."
mkfs.btrfs -f /dev/sda
mount -t btrfs /dev/sda /mnt
for subvol in boot root home roothome var; do
  info "Creating subvolume $subvol"
  btrfs subvolume create /mnt/subvol_$subvol
done
umount /mnt
success "Set up btrfs"

## Mount subvolumes
info "Mounting subvolumes..."
mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
for subvol in boot home var; do
  mkdir /mnt/$subvol
  mount -t btrfs -o subvol=subvol_$subvol /dev/sda /mnt/$subvol
done
mkdir /mnt/root
mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root
success "Mounted subvolumes"

# Base setup
info "Pacstraping packages..."
pacstrap /mnt base base-devel python python2 btrfs-progs openssh grub intel-ucode sudo || fail "Failed to install packages"
success "Installed packages"

info "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab || fail "Failed to generate fstab"
success "Generated fstab"

# And let's finally prepare it to a fully working installation :)
curl -o /mnt/arch_prepare.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_prepare.sh
chmod +x /mnt/arch_prepare.sh

if [ ! -z $1 ]; then
  info 'Found hostname, passing it'
  info "Let's go for nspawn \o/"
  systemd-nspawn -D /mnt ./arch_prepare.sh $1
  if [ $? -nq 0 ]; then
    fail "Failed to start nspawn"
  else
    success "Ended running nspawn"
  fi
else
  info "Let's go for nspawn \o/"
  systemd-nspawn -D /mnt ./arch_prepare.sh
  if [ $? -nq 0 ]; then
    fail "Failed to start nspawn"
  else
    success "Ended running nspawn"
  fi
fi

info "Removing arch_prepare.sh script..."
rm /mnt/arch_prepare.sh
sync
info "Unmounting /mnt..."
umount -R /mnt

# In case you want to mount everything like previously but by hand...
# mount -t btrfs -o subvol=subvol_root /dev/sda /mnt/
# mount -t btrfs -o subvol=subvol_home /dev/sda /mnt/home
# mount -t btrfs -o subvol=subvol_boot /dev/sda /mnt/boot
# mount -t btrfs -o subvol=subvol_roothome /dev/sda /mnt/root
# mount -t btrfs -o subvol=subvol_var /dev/sda /mnt/var
