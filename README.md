# Short tutorial about installing GPIB on a Raspberry Pi

The purpose of this repository is to prepare a Raspberry Pi as a GPIB controller and make this as easy as possible. The provided installation bash script will install the following things:

- linux-gpib
- PyVISA for Python3
- Driver for Agilent 82357A
- Testgear lib (https://github.com/PhilippCo/testgear)

The linux-gpib setup is based on MiDis description on the EEVBlog Forum: https://www.eevblog.com/forum/metrology/raspberry-pi23-logging-platform-for-voltnuts/msg2008349/#msg2008349


If you want to use the Raspberry Pi like an Agilent E5810A Ethernet to GPIB Bridge you could also install https://github.com/PhilippCo/python-vxi11-server

## install Raspbian

[Install Raspberry Pi Image](install_image.md)

## Update Raspbian and install everything you need

log in via ssh or console and just copy and paste these two lines one after the other

```
sudo apt update && sudo apt -y upgrade && sudo apt -y install git
mkdir ~/repos && cd ~/repos && git clone https://github.com/PhilippCo/meas_rpi.git && meas_rpi/install_gpib.sh
```  

