#!/bin/sh

echo "installing python"
sudo apt install python3 python3-pip -y
sudo pip3 install --upgrade pip
echo "installing python libs"
sudo pip3 install influxdb psutil

echo "getting test script"
curl -fsSL https://raw.githubusercontent.com/wildfireone/hubsensornet/master/read.py?token=AXQeLhpi-1aFm3TdYbW-wt5ketyi_1NMks5bOh_dwA%3D%3D | sudo tee /read.py > /dev/null
echo "adding test script to autorun"
sudo sed -i '$ipython3 /read.py &' /etc/rc.local