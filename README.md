# hubsensornet

This project explores the ability to use Raspberry Pi's to build a sensor network runnig atop the eduroam network.

Any amount of Raspberry Pi's can be used as long as there is a Raspberry Pi [2/3] running the "server" ( As node.js is only available for ARMv7 and ARMv8 and not for the ARMv6 which the Zero and 1 uses). This is the only hard requirement imposed, ny editing the [wpa_supplicant](lib/wpa_supplicant.conf) file to fit your needs. 

Once the [prepsd.sh](prepsd.sh) has been run and a Raspberry Pi is running the server software, direct your browser to [pihost:8080](http://pihost:8080) (Hostname should be resolved by the [avahi-daemon](https://linux.die.net/man/8/avahi-daemon) running on the Raspberry Pi.
