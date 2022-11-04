# Setup GPIB on Raspberry Pi
#
# steps are based on MiDis description: https://www.eevblog.com/forum/metrology/raspberry-pi23-logging-platform-for-voltnuts/msg2008349/#msg2008349
#

export DEBIAN_FRONTEND=noninteractive

sudo apt-get -y autoremove

#install build tools
sudo apt-get -y install subversion
sudo apt-get -y install build-essential
sudo apt-get -y install texinfo 
sudo apt-get -y install texi2html 
sudo apt-get -y install libcwidget-dev 
sudo apt-get -y install tcl8.6-dev 
sudo apt-get -y install tk8.6-dev 
sudo apt-get -y install libncurses5-dev 
sudo apt-get -y install libx11-dev 
sudo apt-get -y install binutils-dev 
sudo apt-get -y install bison 
sudo apt-get -y install flex
sudo apt-get -y install libusb-1.0-0 
sudo apt-get -y install libusb-dev 
sudo apt-get -y install libmpfr-dev 
sudo apt-get -y install libexpat1-dev 
sudo apt-get -y install tofrodos 
sudo apt-get -y install autoconf 
sudo apt-get -y install automake 
sudo apt-get -y install libtool 
sudo apt-get -y install libpython3-dev
#sudo apt-get -y install libpython-dev

#Redis
sudo apt-get -y install redis-server
pip3 install -U redis

#install some common tools
sudo apt-get -y install tmux
sudo apt-get -y install mc

#install tools to export LaTex & PDF from Jupyter
sudo apt-get -y install pandoc 
sudo apt-get -y install texlive-xetex

#before we go on: check if subversion is really installed. That was sometimes a problem in the past
if ! command -v svn &> /dev/null
then
    echo "subversion failed to install!"
    exit
fi

#install python GPIB before linux-gpib!
sudo apt-get -y install python3-pip
sudo apt-get -y install libatlas-base-dev
sudo apt-get -y install python3-smbus

sudo apt-get -y install libopenblas-dev liblapack-dev
sudo apt-get -y install gfortran

pip3 install -U numpy pyvisa pyvisa-py scipy openpyxl pandas xlrd openpyxl pyserial pyusb


#install Jupyter Lab as a service
sudo apt-get -y install libffi-dev
pip3 install -U setuptools cffi pygments testresources

#create directory for Jupyter Notebooks
mkdir ~/notebooks
pip3 install 'importlib-metadata<4'
pip3 install jupyterlab
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
sudo make
sudo make install

#install User Module
cd /usr/local/src/linux-gpib-code/linux-gpib-user/
#sudo make clean
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install


#Install Agilent 82357a
cd /usr/local/src/linux-gpib-code/
sudo apt-get -y install fxload
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

#create gpib group
sudo groupadd gpib
sudo adduser pi gpib

#allow access to USB devices
sudo echo 'SUBSYSTEM=="usb", MODE="0666", GROUP="gpib"' >> /etc/udev/rules.d/99-com.rules

sudo ldconfig
sudo gpib_config

#install VXI11 server
sudo systemctl enable rpcbind
sudo systemctl start rpcbind
cd ~/repos
git clone https://github.com/PhilippCo/python-vxi11-server.git
sudo cp python-vxi11-server/vxi-bridge.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vxi-bridge.service
sudo systemctl start vxi-bridge.service
sudo systemctl status vxi-bridge.service


#install testgear lib
cd ~/repos
git clone https://github.com/PhilippCo/testgear.git
cd testgear
pip3 install -e ./


# install matplotlib
pip3 install -U matplotlib ipympl
sudo apt-get -y install libtiff5
sudo apt-get -y install libopenjp2-7
cd ~
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get -y install nodejs
/home/pi/.local/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager
/home/pi/.local/bin/jupyter labextension install jupyter-matplotlib
/home/pi/.local/bin/jupyter nbextension enable --py widgetsnbextension


#create IPython config
/home/pi/.local/bin/ipython profile create

#switch Jedi auto-completion off (very slow)
echo 'c.Completer.use_jedi = False' >>  /home/pi/.ipython/profile_default/ipython_config.py


echo "generate SSH key"
ssh-keygen -b 4096 -t rsa -f /home/pi/.ssh/id_rsa -q -N ""


#add Cron Jobs
mkdir ~/notebooks/cron
mkdir ~/notebooks/cron/nightly
mkdir ~/notebooks/cron/hourly
chmod 777 /home/pi/repos/meas_rpi/scripts/cron_nightly.sh
chmod 777 /home/pi/repos/meas_rpi/scripts/cron_hourly.sh
(crontab -l 2>/dev/null; echo "30 2 * * * /home/pi/repos/meas_rpi/scripts/cron_nightly.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 * * * * /home/pi/repos/meas_rpi/scripts/cron_hourly.sh") | crontab -

echo "installation done.."
echo "please reboot (type: sudo reboot)"
