#!/bin/sh

# install buttonsd
sudo apt-get install -y build-essential python3-dev python3-pip python3-setuptools netcat
sudo pip3 install RPi.GPIO
sudo cp ~osmc/buttonsd/buttonsd.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now buttonsd

# install vlc player + sound settings
sudo apt-get install -y alsa-utils
sudo amixer cset numid=3 1
sudo ln -s /home/osmc/cdrom.rules /etc/udev/rules.d/82-cdrom.rules
cp kodi-files/userdata/playercorefactory.xml ~/.kodi/userdata

# install libdvdcss
sudo apt-get install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg

# enable i2c
sudo apt-get install -y python3-smbus i2c-tools
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
sudo apt-get install -y lcdproc
git clone https://github.com/adafruit/Adafruit_Python_SSD1306.git
cd Adafruit_Python_SSD1306
sudo python3 setup.py install
sudo ln -s /home/osmc/lcdd-oled/lcdd-oled.service /etc/systemd/system/multi-user.target.wants/lcdd-oled.service
kodi-send --action="InstallAddon(script.xbmc.lcdproc)"
cp kodi-files/userdata/LCD.xml ~/.kodi/userdata


# TODO Install Replay Add-ons
kodi-send --action="InstallAddon(plugin.video.francetv)"
kodi-send --action="InstallAddon(plugin.video.catchuptvandmore)"
kodi-send --action="InstallAddon(plugin.audio.jambmc)"
