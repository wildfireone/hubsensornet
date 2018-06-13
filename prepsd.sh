#!/bin/bash

if [ ! -f 2018-04-18-raspbian-stretch-lite.img ]; then
    if [ ! -f 2018-04-18-raspbian-stretch-lite.zip ]; then
        echo -e "no image or zip found, getting from raspberrypi.org\\n"
        wget -q --show-progress --content-disposition "https://downloads.raspberrypi.org/raspbian_lite_latest"
    fi
    echo -e "zip found, unpacking\\n"
    unzip 2018-04-18-raspbian-stretch-lite.zip
fi

if ! lsblk | grep -q mmcblk0 ; then
    echo "no sd card found please plug one in"
    exit 1
fi

echo "this will erase all data on the sd card, are you sure?"
read -p "Are you sure? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo dd if=2018-04-18-raspbian-stretch-lite.img bs=4M of=/dev/mmcblk0 status=progress && sync
else
    exit 1
fi

echo -e "creating directories\\n"
if [ -d /mnt/sd/boot ]; then sudo mkdir -p /mnt/sd/boot; fi
if [ -d /mnt/sd/root ]; then sudo mkdir /mnt/sd/root; fi

echo -e "mounting drives\\n"
sudo mount /dev/mmcblk0p1 /mnt/sd/boot
sudo mount /dev/mmcblk0p2 /mnt/sd/root

echo -e "moving files\\n"
sudo touch /mnt/sd/boot/ssh
echo -e "if [ -e /setup.sh ]; then sudo bash /setup.sh $1 && sudo rm /setup.sh; fi" | sudo tee -a /mnt/sd/root/etc/rc.local >> /dev/null
sudo cp ./setup.sh /mnt/sd/root/

echo "unmounting drives"
sudo umount /mnt/sd/boot
sudo umount /mnt/sd/root