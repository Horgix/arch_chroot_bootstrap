#! /bin/bash

apt-get install -y haveged
systemctl start haveged
cd /tmp
curl -O http://mir.archlinux.fr/iso/2017.06.01/archlinux-bootstrap-2017.06.01-x86_64.tar.gz
tar xzf ./archlinux-bootstrap-2017.06.01-x86_64.tar.gz
echo "$(awk 'c&&c--{sub(/^#/,"")} /## France/{c=8} 1' /tmp/root.x86_64/etc/pacman.d/mirrorlist)" > /tmp/root.x86_64/etc/pacman.d/mirrorlist
curl -o /tmp/root.x86_64/arch_init.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_init.sh
chmod +x /tmp/root.x86_64/arch_init.sh
if [ $1 == "--fullinstall" ]; then
  echo 'Running a full install...'
  if [ ! -z $2 ]; then
    echo 'Found hostname, passing it'
    /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/ ./arch_init.sh $2
  else
    /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/ ./arch_init.sh
  fi
else
  echo 'No full install, just chrooting you'
  /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/
fi
