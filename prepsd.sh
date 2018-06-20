#!/bin/bash

if [ "$1" = "1" ]; then
    a=$1
    name="pihost"
    echo "server $name"
    elif [ "$1" = "0" ]; then
    a=$1
    if [[ "$2" =~ ^[0-9]+$ ]]; then
        name=pitest$2
        echo "client $name"
    else
        echo "choose a number for the client pi"
        exit 1
    fi
else
    echo "no choice made, choose client(0) or server(1)"
    exit 1
fi

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
    echo a
    # exit 1
fi

echo -e "creating directories\\n"
if [ ! -d /mnt/sd/boot ]; then sudo mkdir -p /mnt/sd/boot; fi
if [ ! -d /mnt/sd/root ]; then sudo mkdir /mnt/sd/root; fi

echo -e "mounting drives\\n"
sudo mount /dev/mmcblk0p1 /mnt/sd/boot
sudo mount /dev/mmcblk0p2 /mnt/sd/root

sleep 1

echo -e "moving files\\n"
sudo touch /mnt/sd/boot/ssh
# sudo sed -i "\$iif [ -e /setup.sh ]; then sudo bash /setup.sh $a if [ $? -eq 0 ]; then sudo rm /setup.sh && sudo reboot; fi elif [ -e /setup2.sh ]; then sudo bash /setup2.sh $a && sudo rm /setup2.sh && sudo reboot; fi" /mnt/sd/root/etc/rc.local
sudo sed -i "\$iif [ -e /setup.sh ]; then sudo bash /setup.sh $a && sudo rm /setup.sh && sudo reboot; elif [ -e /setup2.sh ]; then sudo bash /setup2.sh $a && sudo rm /setup2.sh && sudo reboot; fi" /mnt/sd/root/etc/rc.local
echo "$name" | sudo tee /mnt/sd/root/etc/hostname > /dev/null
sudo sed -i "s/raspberrypi/$name/" /mnt/sd/root/etc/hosts
sudo cp ./setup.sh /mnt/sd/root/
sudo cp ./setup2.sh /mnt/sd/root/

sleep 1
sync

echo "unmounting drives"
sudo umount /mnt/sd/boot
sudo umount /mnt/sd/root