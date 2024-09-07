#!/bin/bash

sudo cp hooks /etc/libvirt/hooks/qemu
sudo cp grub /etc/default/grub 
sudo cp mkinitcpio.conf /etc/mkinitcpio.conf 
sudo cp xorg /etc/X11/xorg.conf 
sudo cp modprobe/etc/modprobe.d
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -p linux
