#! /bin/bash

pacman-key --init
pacman-key --populate archlinux
pacman -Syu
pacman -S base
