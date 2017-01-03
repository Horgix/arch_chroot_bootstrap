#! /bin/bash

apt-get install -y haveged
systemctl start haveged
cd /tmp
curl -O https://mirrors.kernel.org/archlinux/iso/2016.12.01/archlinux-bootstrap-2016.12.01-x86_64.tar.gz
tar xzf ./archlinux-bootstrap-2016.12.01-x86_64.tar.gz
echo "$(awk 'c&&c--{sub(/^#/,"")} /## France/{c=8} 1' /tmp/root.x86_64/etc/pacman.d/mirrorlist)" > /tmp/root.x86_64/etc/pacman.d/mirrorlist
curl -o /tmp/root.x86_64/arch_init.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_init.sh
chmod +x /tmp/root.x86_64/arch_init.sh
/tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/
