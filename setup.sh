#!/bin/bash

net=false
while $net ; do
    wget -q --spider www.google.com
    if [ $? -eq 1 ]; then
        echo "no internet waiting 5 then trying again"
        sleep 5
    else
        net=true
    fi
done

function client {
    echo "installing python"
    sudo apt install python3 python3-pip -y
    sudo pip3 install --upgrade pip
    echo "installing python libs"
    sudo pip3 install influxdb psutil Adafruit_DHT
    
    echo "getting test script"
    curl -fsSL https://raw.githubusercontent.com/decantr/hubsensorcode/master/read.py | sudo tee /read.py > /dev/null
    echo "adding test script to autorun"
    sudo sed -i '$ipython3 /read.py &' /etc/rc.local
}

function server {
    echo "installing docker"
    curl -fsSL get.docker.com | sudo sh
    sudo usermod -aG docker pi
    
    docker create --name pidb --restart=always --network pinet -p 8086:8086 influxdb
    
    docker start pidb
    
    sleep 10
    curl -G 'http://localhost:8086/query' --data-urlencode "q=create database test"
}

if [ "$1" == "0" ]; then
    client
    elif [ "$1" == "1" ]; then
    server
fi

echo chaning password
echo "pi:pi" | sudo chpasswd

echo rebooting

exit 0