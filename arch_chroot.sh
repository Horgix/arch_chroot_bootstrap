#! /bin/bash

apt-get install haveged
systemctl start haveged
cd /tmp
curl -O https://mirrors.kernel.org/archlinux/iso/2016.12.01/archlinux-bootstrap-2016.12.01-x86_64.tar.gz
tar xzf ./archlinux-bootstrap-2016.12.01-x86_64.tar.gz
echo "$(awk 'c&&c--{sub(/^#/,"")} /## France/{c=8} 1' /tmp/root.x86_64/etc/pacman.d/mirrorlist)" > /tmp/root.x86_64/etc/pacman.d/mirrorlist
