#install Kernel Module
cd /usr/local/src/linux-gpib-code/linux-gpib-kernel/
sudo make clean
sudo make
sudo make install

#install User Module
cd /usr/local/src/linux-gpib-code/linux-gpib-user/
sudo make clean
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install

echo ----------------------
echo - DONE please reboot -
echo ----------------------