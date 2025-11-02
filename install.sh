# Setup GPIB on Raspberry Pi
#
# steps are based on MiDis description: https://www.eevblog.com/forum/metrology/raspberry-pi23-logging-platform-for-voltnuts/msg2008349/#msg2008349
#


sudo apt-get -y autoremove

#install build tools
sudo apt -y install subversion
sudo apt -y install build-essential
#sudo apt -y install bison flex  ## still neded without LaTex?
sudo apt -y install automake libtool

#sudo apt-get -y install libpython3-dev
sudo apt -y install libopenblas-dev liblapack-dev
sudo apt -y install libopenjp2-7

#install some common tools
sudo apt-get -y install tmux mc


#before we go on: check if subversion is really installed. That was sometimes a problem in the past
if ! command -v svn &> /dev/null
then
    echo "subversion failed to install!"
    exit
fi

#install python GPIB before linux-gpib!
sudo apt -y install python3 python3-pip python3-venv nodejs
sudo apt-get -y install python3-smbus

cd ~
python3 -m venv venv
~/venv/bin/python3 -m pip install jupyter
~/venv/bin/python3 -m pip install pyvisa pyvisa-py scipy openpyxl pandas xlrd pyserial pyusb
~/venv/bin/python3 -m pip install matplotlib ipympl

#install Redis
sudo apt-get -y install redis-server
~/venv/bin/python3 -m pip install redis


#install Jupyter Lab as a service
#create directory for Jupyter Notebooks
mkdir ~/notebooks
sudo cp ~/repos/meas_rpi/jupyter/jupyter.service /etc/systemd/system/
sudo systemctl enable jupyter.service
sudo systemctl daemon-reload
sudo systemctl start jupyter.service
#jupyter notebook --generate-config
## set password later with: jupyter notebook password
ln -s ~/repos/meas_rpi/jupyter/examples ~/notebooks/examples
ln -s ~/repos/meas_rpi/jupyter/maintenance ~/notebooks/maintenance
mkdir ~/notebooks/maintenance/backups

#check out linux-gpib
sudo svn checkout http://svn.code.sf.net/p/linux-gpib/code/trunk /usr/local/src/linux-gpib-code

#install Kernel Module
cd /usr/local/src/linux-gpib-code/linux-gpib-kernel/
sudo make clean
sudo sed -i 's/GPIOF_DIR_IN/GPIOD_IN/g' drivers/gpib/gpio/gpib_bitbang.c
sudo make
sudo make install

#install User Module
cd /usr/local/src/linux-gpib-code/linux-gpib-user/
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install

#install gpib in venv
sudo ~/venv/bin/python3 -m pip install -e /usr/local/src/linux-gpib-code/linux-gpib-user/language/python/


#Install Agilent 82357a
cd /usr/local/src/linux-gpib-code/
sudo apt-get -y install fxload
sudo wget http://linux-gpib.sourceforge.net/firmware/gpib_firmware-2008-08-10.tar.gz
sudo tar xvzf gpib_firmware-2008-08-10.tar.gz
#cd /usr/local/src/linux-gpib-code/gpib_firmware-2008-08-10/agilent_82357a/

#backup original gpib.conf
sudo mv /usr/local/etc/gpib.conf /usr/local/etc/gpib.conf.backup

#replace gpib.conf with modified one
sudo cp ~/repos/meas_rpi/gpib/gpib.conf /usr/local/etc/

#auto download firmware
sudo cp /usr/local/src/linux-gpib-code/gpib_firmware-2008-08-10/agilent_82357a/measat_releaseX1.8.hex $(sudo find / -type d -name 'agilent_82357a' | grep usb | grep -v gpib)

sudo cp /usr/local/etc/udev/rules.d/* /etc/udev/rules.d/

#create gpib group
sudo groupadd gpib
sudo adduser $(whoami) gpib

#allow access to USB devices
echo 'SUBSYSTEM=="usb", MODE="0666", GROUP="gpib"' | sudo tee -a /etc/udev/rules.d/99-com.rules

sudo ldconfig
sudo gpib_config


#install testgear lib
cd ~/repos
git clone https://github.com/PhilippCo/testgear.git
cd testgear
sudo ~/venv/bin/pip3 install -e ./


echo "generate SSH key"
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""


#add Cron Jobs
mkdir ~/notebooks/cron
mkdir ~/notebooks/cron/nightly
mkdir ~/notebooks/cron/hourly
chmod 777 ~/repos/meas_rpi/scripts/cron_nightly.sh
chmod 777 ~/repos/meas_rpi/scripts/cron_hourly.sh
(crontab -l 2>/dev/null; echo "30 2 * * * /home/pi/repos/meas_rpi/scripts/cron_nightly.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 * * * * /home/pi/repos/meas_rpi/scripts/cron_hourly.sh") | crontab -

echo 
echo 
echo "#################################################"
echo "# installation done..                           #"
echo "# please reboot (type: sudo reboot)             #"
echo "#################################################"

