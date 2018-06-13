#!/bin/bash

function client {
    
    echo begining config
    
    if ! grep -qe 'ssid="pihost"' /etc/wpa_supplicant/wpa_supplicant.conf; then
        echo adding wifi config
        echo -e 'country=GB\n\nnetwork={\n ssid="pihost"\n psk="thereoncewasapi"\n}' >> /dev/null # /etc/wpa_supplicant/wpa_supplicant.conf
    else
        echo wifi config already found, updating
        sudo sed 's/ssid=.*/ssid="pihost"/' /etc/wpa_supplicant/wpa_supplicant.conf
        sudo sed 's/psk=.*/psk="thereoncewasapi"/' /etc/wpa_supplicant/wpa_supplicant.conf
    fi
    finish
}

function server {
    # check internet
    wget -q --spider www.google.com
    if [ $? -eq 1 ]; then
        echo "no internet, exiting"
        exit 1
    fi
    ap
    #	dock
    finish
}

function ap {
    echo intsalling software
    sudo apt install dnsmasq hostapd
    sudo systemctl stop dnsmasq
    sudo systemctl stop hostapd
    
    echo -e "interface wlan0\\n static ip_address=192.168.4.1/24" >> /etc/dhcpcd.conf
    sudo service dhcpcd restart
    
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    
    echo -e "interface=wlan0\\ndhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h" >> /etc/dnsmasq.conf
    
    echo -e "interface=wlan0\\ndriver=nl80211\\nssid=pihost\\nhw_mode=g\\nchannel=7\\nwmm_enabled=0\\nmacaddr_acl=0\\nauth_algs=1\\nignore_broadcast_ssid=0\\nwpa=2\\nwpa_passphrase=thereoncewasapi\\nwpa_key_mgmt=WPA-PSK\\nwpa_pairwise=TKIP\\nrsn_pairwise=CCMP\\n"
    
    sudo sed -i 's*#DAEMON_CONF=""*DAEMON_CONF="/etc/hostapd/hostapd.conf"*' /etc/default/hostapd
    
    sudo systemctl start hostapd
    sudo systemctl start dnsmasq
    
    sudo sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
    
    sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
    
    sudo sed -i '$iiptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local
}

function dock {
    curl -fsSL get.docker.com | sudo bash
    sudo usermod -aG docker piq
}

function finish {
    echo chaning password
    echo "pi:pi" | sudo chpasswd
    
    echo rebooting
    sudo reboot
}

if [ "$1" == "0" ]; then
    client
    elif [ "$1" == "1" ]; then
    server
else
    echo "choose either client (0) or server(1)"
    exit 1
fi