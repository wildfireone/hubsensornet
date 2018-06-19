#!/bin/sh

echo "installing python"
sudo apt install python3 python3-pip -y
sudo pip3 install --upgrade pip
echo "installing python libs"
sudo pip3 install influxdb psutil

echo "getting test script"
curl -fsSL https://goo.gl/4scTwR | sudo tee -a /read.py > /dev/null
echo "adding test script to autorun"
sudo sed -i '$ipython3 /read.py &' /etc/rc.local