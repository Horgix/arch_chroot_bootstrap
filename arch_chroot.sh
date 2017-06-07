#! /bin/bash

# Setup haveged to have enough entropy later on
apt-get install -y haveged
systemctl start haveged

# We want nspawn
apt-get install -y systemd-container

# We just want a temporary arch in a chroot, so do it in /tmp
cd /tmp
curl -O http://mir.archlinux.fr/iso/2017.06.01/archlinux-bootstrap-2017.06.01-x86_64.tar.gz
tar xzf ./archlinux-bootstrap-2017.06.01-x86_64.tar.gz
echo "$(awk 'c&&c--{sub(/^#/,"")} /## France/{c=8} 1' /tmp/root.x86_64/etc/pacman.d/mirrorlist)" > /tmp/root.x86_64/etc/pacman.d/mirrorlist

# Actually, I have an arch_init.sh script to install a new Arch so let's get it
curl -o /tmp/root.x86_64/arch_init.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_init.sh
chmod +x /tmp/root.x86_64/arch_init.sh

# Much smart. So clean. Wow.
if [ $1 == "--fullinstall" ]; then
  echo 'Running a full install...'
  if [ ! -z $2 ]; then
    echo 'Found hostname, passing it'
    systemd-nspawn -D /tmp/root.x86_64/ ./arch_init.sh $2
  else
    systemd-nspawn -D /tmp/root.x86_64/ ./arch_init.sh
  fi
else
  echo 'No full install, just chrooting you'
  /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/
fi
