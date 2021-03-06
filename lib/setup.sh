#!/bin/bash

net=false
until $net ; do
	if wget -q --spider www.google.com ; then
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

	echo "adding read script to autorun"
	sudo sed -i '$ipython /read.py &' /etc/rc.local
}

function server {

	sleep 30

	echo "intsalling dnsmasq and git"
	sudo apt install dnsmasq git
	sudo systemctl start dnsmasq

	sudo touch /setup.sh.log
	echo "installing docker" | sudo tee -a /setup.sh.log
	curl -kfsSL get.docker.com | sudo bash | sudo tee -a /setup.docker.log
	echo "docker installed " | sudo tee -a /setup.sh.log
	sudo usermod -aG docker pi

	echo "creating pidb container" | sudo tee -a /setup.sh.log
	sudo docker create --name pidb --restart=always -p 8086:8086 influxdb
	sudo docker start pidb

	echo "installing node" | sudo tee -a /setup.sh.log
	cd /tmp || return
	wget https://nodejs.org/dist/v10.8.0/node-v10.8.0-linux-armv7l.tar.xz
	tar xf node-v10.8.0-linux-armv7l.tar.xz
	cd node-v10.8.0-linux-armv7l/ || echo "ERROR: failed to get node" | sudo tee -a /setup.sh.log && return
	sudo mv bin/* /bin/
	sudo mv lib/* /lib/
	sudo mv share/* /usr/share/

	sudo chown -R pi:pi /server

	echo "install dependencies" | sudo tee -a /setup.sh.log
	cd /server || echo "ERROR: server not copied over" | sudo tee -a /setup.sh.log && return
	npm i -s express http-server
	cd ~ || return

	echo "adding server to autorun"
	sudo sed -i '$inode /server/server.js &' /etc/rc.local
	sudo sed -i '$i/server/node_modules/http-server/bin/http-server /server &' /etc/rc.local

	sleep 10
	curl -XPOST 'http://localhost:8086/query' --data-urlencode "q=create database test"
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
