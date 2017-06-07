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

header "Base setup"

info "Setting up haveged to have enough entropy later on..."
apt-get install -y haveged  || fail "IGNORE Failed to install haveged"
systemctl start haveged     || fail "Failed to start haveged"
success "Set up haveged"

# We want nspawn
info "Install systemd-nspawn..."
apt-get install -y systemd-container  || fail "IGNORE Failed to install systemd-container"
success "Installed systemd-nspawn"

# We just want a temporary arch in a chroot, so do it in /tmp
info "Getting a temporary Arch for further operations"
cd /tmp
curl -O http://mir.archlinux.fr/iso/2017.06.01/archlinux-bootstrap-2017.06.01-x86_64.tar.gz
tar xzf ./archlinux-bootstrap-2017.06.01-x86_64.tar.gz
echo "$(awk 'c&&c--{sub(/^#/,"")} /## France/{c=8} 1' /tmp/root.x86_64/etc/pacman.d/mirrorlist)" > /tmp/root.x86_64/etc/pacman.d/mirrorlist
success "Got a temporary Arch installed"


# Actually, I have an arch_init.sh script to install a new Arch so let's get it
curl -o /tmp/root.x86_64/arch_init.sh https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_init.sh
chmod +x /tmp/root.x86_64/arch_init.sh

header "Next steps"

# Much smart. So clean. Wow.
if [ "$1" == "--fullinstall" ]; then
  info "Detected --fullinstall ..."
  if [ ! -z $2 ]; then
    info "Please pass $2 as arg to arch_init to set hostname"
    info "Let's go for nspawn \o/"
    systemd-nspawn -b --bind /dev/sda -D /tmp/root.x86_64/ # ./arch_init.sh $2
  else
    info "No hostname found"
    info "Let's go for nspawn \o/"
    systemd-nspawn -b --bind /dev/sda -D /tmp/root.x86_64/ # ./arch_init.sh
  fi
else
  info 'No full install, just chrooting you'
  /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64/
fi
