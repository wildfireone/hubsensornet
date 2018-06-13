
sudo dd if=~/2018-04-18-raspbian-stretch-lite.img bs=4M of=/dev/mmcblk0 status=progress && sync

if [ ! -d /mnt/sd ]; then
    sudo mkdir /mnt/sd/boot
    sudo mkdir /mnt/sd/root
fi
sudo mount /dev/mmcblk0p1 /mnt/sd/boot
sudo mount /dev/mmcblk0p2 /mnt/sd/root

sudo touch /mnt/sd/boot/ssh

sudo echo -e "if [ -e /setup.sh ]; then sudo bash /setup.sh $1 && sudo rm /setup.sh; fi" >> /mnt/sd/root/etc/rc.local

