#! /bin/bash

pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm
pacman -S base --noconfirm
