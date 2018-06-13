#!/bin/bash

if [ ! -a "*-raspbian-stretch-lite.img" ]; then
    if [ -a "*-raspbian-stretch-lite.zip" ]; then
        unzip "*-raspbian-stretch-lite.zip"
    else
        wget -q --show-progress https://downloads.raspberrypi.org/raspbian_lite_latest
        unzip "*-raspbian-stretch-lite.zip"
    fi
fi

if ! lsblk | grep -q mmcblk0 ; then
    echo "no sd card found please plug one in"
    exit 1
fi

sudo dd if=~/2018-04-18-raspbian-stretch-lite.img bs=4M of=/dev/mmcblk0 status=progress && sync

#
sudo mkdir -p /mnt/sd/boot
sudo mkdir /mnt/sd/root

sudo mount /dev/mmcblk0p1 /mnt/sd/boot
sudo mount /dev/mmcblk0p2 /mnt/sd/root

sudo touch /mnt/sd/boot/ssh

sudo echo -e "if [ -e /setup.sh ]; then sudo bash /setup.sh $1 && sudo rm /setup.sh; fi" >> /mnt/sd/root/etc/rc.local
sudo cp ./setup.sh /mnt/sd/root/

