#!/bin/bash

function client {
    
    echo begining config
    
    if ! grep -e 'network={' /etc/wpa_supplicant/wpa_supplicant.conf; then
        echo adding wifi config
        echo -e 'country=GB\n\nnetwork={\n ssid="pihost"\n psk="thereoncewasapi"\n}' | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
    else
        echo wifi config already found, updating
        sudo sed 's/ssid=.*/ssid="pihost"/' /etc/wpa_supplicant/wpa_supplicant.conf
        sudo sed 's/psk=.*/psk="thereoncewasapi"/' /etc/wpa_supplicant/wpa_supplicant.conf
    fi
    finish
}

function server {
    # check internet, cant use ping as its blocked in eduroam
    wget -q --spider www.google.com
    if [ $? -eq 1 ]; then
        echo "no internet, exiting"
        exit 1
    fi
    ap
    dock
    finish
}

function ap {
    echo "intsalling software"
    sudo apt install -y dnsmasq hostapd
    sudo systemctl stop dnsmasq hostapd
    
    echo -e "interface wlan0\\n static ip_address=192.168.4.1/24" >> /etc/dhcpcd.conf
    sudo service dhcpcd restart
    
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    
    sudo touch /etc/dnsmasq.conf
    echo -e "interface=wlan0\\ndhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h" | sudo tee /etc/dnsmasq.conf > /dev/null
    
    echo -e "interface=wlan0\\ndriver=nl80211\\nssid=pihost\\nhw_mode=g\\nchannel=7\\nwmm_enabled=0\\nmacaddr_acl=0\\nauth_algs=1\\nignore_broadcast_ssid=0\\nwpa=2\\nwpa_passphrase=thereoncewasapi\\nwpa_key_mgmt=WPA-PSK\\nwpa_pairwise=TKIP\\nrsn_pairwise=CCMP\\n" | sudo tee /etc/hostapd/hostapd.conf > /dev/null
    
    sudo sed -i 's*#DAEMON_CONF=""*DAEMON_CONF="/etc/hostapd/hostapd.conf"*' /etc/default/hostapd
    
    sudo systemctl start hostapd dnsmasq
    
    sudo sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
    
    sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
    
    sudo sed -i '$iiptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local
}

function dock {
    echo "installing docker"
    curl -fsSL get.docker.com | sudo sh
    sudo usermod -aG docker pi
    
    docker network create pinet
    
    docker create --name pidb --restart=always --network pinet -p 8086:8086 influxdb
    docker create --name piui --restart=always --network pinet -p 3000:3000 fg2it/grafana-armhf:v5.1.3
    
    docker start pidb piui
    
    sleep 10
    curl -G 'http://localhost:8086/query' --data-urlencode "q=create database test"
}

function finish {
    echo chaning password
    echo "pi:pi" | sudo chpasswd
    
    echo rebooting
}

if [ "$1" == "0" ]; then
    client
    elif [ "$1" == "1" ]; then
    server
else
    echo "choose either client (0) or server(1)"
    exit 1
fi

exit 0