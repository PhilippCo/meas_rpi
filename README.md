# Short tutorial about installing GPIB on a Raspberry Pi

The purpose of this repository is to prepare a Raspberry Pi as a GPIB controller and make this as easy as possible. The provided installation bash script will install the following things:

- linux-gpib
- PyVISA for Python3
- Driver for Agilent 82357A (Agilent 82357B)
- support for NI GPIB-USB-HS
- VXI11 Server (poor mans Agilent E5810A GPIB to Ethernet Bridge https://github.com/PhilippCo/python-vxi11-server)
- Testgear lib (https://github.com/PhilippCo/testgear)
- Jupyter Lab as a Service (Passwort: 1281)

The linux-gpib setup is based on MiDis description on the EEVBlog Forum: https://www.eevblog.com/forum/metrology/raspberry-pi23-logging-platform-for-voltnuts/msg2008349/#msg2008349


## install Raspbian

[Install Raspberry Pi Image](install_image.md)

Since some time the default user isn't 'pi' anymore. But a lot of scripts rely on paths for this user. Therefore, it is absolutely neccessary to use the username pi!

## Update Raspbian and install everything you need

log in via ssh or console and just copy and paste these lines one after the other

```
sudo apt update && sudo apt -y upgrade && sudo apt-get -y install --reinstall raspberrypi-bootloader raspberrypi-kernel && sudo apt-get -y install raspberrypi-kernel-headers git && echo 'arm_64bit=0' | sudo tee -a /boot/firmware/config.txt
```

```
sudo reboot
```

After reboot log in again and paste this:
```
mkdir ~/repos && cd ~/repos && git clone https://github.com/PhilippCo/meas_rpi.git && meas_rpi/install.sh
```  

