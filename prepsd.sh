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

if [ ! -f 2018-06-27-raspbian-stretch-lite.img ]; then
    if [ ! -f 2018-06-27-raspbian-stretch-lite.zip ]; then
        echo -e "no image or zip found, getting from raspberrypi.org\\n"
        wget -q --show-progress --content-disposition "https://downloads.raspberrypi.org/raspbian_lite_latest"
    fi
    echo -e "zip found, unpacking\\n"
    unzip 2018-06-27-raspbian-stretch-lite.zip
fi


if ! lsblk | grep -q mmcblk0 ; then
    echo "no sd card detected"
    lsblk | grep -e "disk"
    while [ "$drive" = "" ] ; do
        read -p "Please specify drive: /dev/"
        if lsblk | grep -e "disk" | grep -e $REPLY > /dev/null ; then
            drive="/dev/$REPLY"
        else
            echo "please select an appropriate device"
        fi
    done
else
    drive="/dev/mmcblk0"
fi

echo "this will erase all data on $drive, are you sure?"
read -p "Are you sure? " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo umount $drive $drive\1 $drive\2 $drive\p1 $drive\p2 2> /dev/null
    sudo dd if=2018-06-27-raspbian-stretch-lite.img bs=4M of=$drive status=progress && sync
else
    exit 1
fi

echo -e "creating directories\\n"
if [ ! -d /mnt/sd/boot ]; then sudo mkdir -p /mnt/sd/boot; fi
if [ ! -d /mnt/sd/root ]; then sudo mkdir /mnt/sd/root; fi

if ! echo $drive | grep -e "sd" ; then
    $drive=$drive\p
fi
echo -e "mounting drives\\n"
sudo mount $drive\1 /mnt/sd/boot
sudo mount $drive\2 /mnt/sd/root

sleep 1

echo -e "moving files\\n"
sudo touch /mnt/sd/boot/ssh
sudo cp wpa_supplicant.conf /mnt/sd/boot/
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