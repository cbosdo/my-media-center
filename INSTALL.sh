#!/bin/sh

# install buttonsd
sudo apt-get install -y build-essential python-dev python-pip python-setuptools netcat
sudo pip install RPi.GPIO
sudo ln -s /home/osmc/buttonsd/buttonsd.service /etc/systemd/system/multi-user.target.wants/buttonsd.service
sudo systemctl daemon-reload
sudo systemctl start buttonsd

# install vlc player + sound settings
sudo apt-get install -y alsa-utils
sudo amixer cset numid=3 1
sudo ln -s /home/osmc/cdrom.rules /etc/udev/rules.d/82-cdrom.rules
cp kodi-files/userdata/playercorefactory.xml ~/.kodi/userdata

# enable i2c
sudo apt-get install -y python-smbus i2c-tools
echo '>>> Enable I2C'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q 'i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q 'dtparam=i2c1=on' /boot/config.txt; then
  echo 'Seems i2c1 parameter already set, skip this step.'
else
  echo 'dtparam=i2c1=on' >> /boot/config.txt
fi
if grep -q 'dtparam=i2c_arm=on' /boot/config.txt; then
  echo 'Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi
if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then
  sed -i 's/^blacklist spi-bcm2708/#blacklist spi-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
  sed -i 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
else
  echo 'File raspi-blacklist.conf does not exist, skip this step.'
fi

# install OLED
sudo apt-get install -y lcddproc
git clone https://github.com/adafruit/Adafruit_Python_SSD1306.git
cd Adafruit_Python_SSD1306
sudo python setup.py install
sudo ln -s /home/osmc/lcdd-oled/lcdd-oled.service /etc/systemd/system/multi-user.target.wants/lcdd-oled.service
kodi-send --action="InstallAddon(script.xbmc.lcdproc)"
cp kodi-files/userdata/LCD.xml ~/.kodi/userdata

# install code poweroff button
ln -s /home/osmc/switch/switch.service /etc/systemd/system/multi-user.target.wants/switch.service
sudo systemctl daemon-reload
sudo systemctl start switch


# TODO Install Replay Add-ons
