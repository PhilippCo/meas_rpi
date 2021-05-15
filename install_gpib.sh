# Setup GPIB on Raspberry Pi
#
# All steps based on MiDis description: https://www.eevblog.com/forum/metrology/raspberry-pi23-logging-platform-for-voltnuts/msg2008349/#msg2008349
#

#install kernel headers
sudo apt-get install raspberrypi-kernel-headers && [ -d /usr/src/linux-headers-$(uname -r) ]

#install build tools
sudo apt-get install build-essential texinfo texi2html libcwidget-dev tcl8.6-dev tk8.6-dev libncurses5-dev libx11-dev binutils-dev bison flex libusb-1.0-0 libusb-dev libmpfr-dev libexpat1-dev tofrodos subversion autoconf automake libtool libpython3-dev libpython-dev


#check out linux-gpib
sudo svn checkout svn://svn.code.sf.net/p/linux-gpib/code/trunk /usr/local/src/linux-gpib-code

#install User Module
cd /usr/local/src/linux-gpib-code/linux-gpib-kernel/
sudo make
sudo make install

#install Kernel Module
cd /usr/local/src/linux-gpib-code/linux-gpib-user/
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install


#Install Agilent 82357a
cd /usr/local/src/linux-gpib-code/
sudo apt-get install fxload
sudo wget http://linux-gpib.sourceforge.net/firmware/gpib_firmware-2008-08-10.tar.gz
sudo tar xvzf gpib_firmware-2008-08-10.tar.gz
cd /usr/local/src/linux-gpib-code/gpib_firmware-2008-08-10/agilent_82357a/

#backup original gpib.conf
sudo mv /usr/local/etc/gpib.conf /usr/local/etc/gpib.conf.backup

#replace gpib.conf with modified one
sudo cp ~/repos/meas_rpi/gpib/gpib.conf /usr/local/etc/

#auto download firmware
sudo cp /usr/local/src/linux-gpib-code/gpib_firmware-2008-08-10/agilent_82357a/measat_releaseX1.8.hex $(sudo find / -type d -name 'agilent_82357a' | grep usb | grep -v gpib)

sudo cp /usr/local/etc/udev/rules.d/* /etc/udev/rules.d/

sudo groupadd gpib


echo installation done..
echo please reboot
