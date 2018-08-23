#!/bin/bash

net=false
until $net ; do
    wget -q --spider www.google.com
    if [ $? -eq 0 ]; then
      net=true
    else
      echo "no internet waiting 5 before trying again"
      sleep 5
    fi
done

function client {
    echo "installing pip"
    sudo apt install python-pip -y
    sudo pip install --upgrade pip
    echo "installing python libs"
    sudo pip install influxdb psutil Adafruit_DHT

    echo "getting test script"
    curl -fsSL https://raw.githubusercontent.com/decantr/hubsensorcode/master/read.py | sudo tee /read.py > /dev/null
    echo "adding test script to autorun"
    sudo sed -i '$ipython /read.py &' /etc/rc.local
}

function server {
    echo "installing docker"
    curl -fsSL get.docker.com | sudo sh
    sudo usermod -aG docker pi

    echo "creating pidb container"
    docker create --name pidb --restart=always -p 8086:8086 influxdb
    docker start pidb

    # TODO turn this into a node package
    echo "getting server files"
    sudo mkdir /server
    curl -fsSL https://raw.githubusercontent.com/decantr/hubsensorcode/master/server.js | sude tee /server/server.json > /dev/null

    echo "installing node"
    # install node
    echo "install dependencies"
    # install deps

    echo "adding server to autorun"
    sudo sed -i '$inode /server/server.js &' /etc/rc.local

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
