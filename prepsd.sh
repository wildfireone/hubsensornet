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

echo -e "this will erase all data on the sd card, are you sure?\n"
read -p "Are you sure? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo dd if="*-raspbian-stretch-lite.img" bs=4M of=/dev/mmcblk0 status=progress && sync
else
    exit 1
fi

#
sudo mkdir -p /mnt/sd/boot
sudo mkdir /mnt/sd/root

sudo mount /dev/mmcblk0p1 /mnt/sd/boot
sudo mount /dev/mmcblk0p2 /mnt/sd/root

sudo touch /mnt/sd/boot/ssh
echo -e "if [ -e /setup.sh ]; then sudo bash /setup.sh $1 && sudo rm /setup.sh; fi" | sudo tee -a /mnt/sd/root/etc/rc.local
sudo cp ./setup.sh /mnt/sd/root/

sudo umount /mnt/sd/boot
sudo umount /mnt/sd/root