# What

Basic shell script to bootstrap a functionnal Arch Linux chroot to be used from
other Linux distributions.

# Why

When you have servers hosted by a provider, you might be limited on what you
can boot on for recovery purpose. This is my case with
[Online](https://www.online.net/en) servers.

This script has been made to get a minimal working Arch Linux chroot on their
Ubuntu 16.04 recovery image booted from PXE. This allows me to make sure I get
the tools I need, including specific stuff like `pacstrap` (even if, yes, it
could be installed while on Ubuntu without this chroot) to install new systems.

# How to

```
wget https://raw.githubusercontent.com/Horgix/arch_chroot_bootstrap/master/arch_chroot.sh && chmod +x arch_chroot.sh && ./arch_chroot.sh
```
