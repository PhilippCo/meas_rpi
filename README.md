# install Raspbian

[Install Raspberry Pi Image](install_image.md)

# prepare

log in via ssh or console

  sudo apt update
  
  sudo apt -y upgrade


  sudo apt -y install git
  
  
  mkdir ~/repos
  
  cd ~/repos
  
  git clone https://github.com/PhilippCo/meas_rpi.git
  
  meas_rpi/install_gpib.sh
  
  
