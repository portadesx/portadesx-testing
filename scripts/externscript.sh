#!/bin/sh
# Initializing nosnap..
echo 'Adding Debian Repository...'
sudo wget -q http://ftp.us.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.3+deb12u2_all.deb
sudo dpkg -i debian-archive-keyring_2023.3+deb12u2_all.deb
sudo rm debian-archive-keyring_2023.3+deb12u2_all.deb
sudo echo 'deb https://deb.debian.org/debian/ bookworm contrib main non-free non-free-firmware
deb https://security.debian.org/debian-security/ bookworm-security contrib main non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.list
echo 'Adding Mozilla Repository...'
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
sudo echo 'deb [arch=arm64 signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main' >> /etc/apt/sources.list.d/mozilla.list
echo 'Adding Mozillateam PPA...'
sudo add-apt-repository ppa:mozillateam/ppa -y
echo 'Configuring APT Pinning...'
sudo echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1001

Package: *
Pin: origin deb.debian.org
Pin-Priority: 1

Package: *
Pin: origin security.debian.org
Pin-Priority: 1

Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1000

Package: chromium
Pin: origin security.debian.org
Pin-Priority: 1000

Package: chromium-common
Pin: origin security.debian.org
Pin-Priority: 1000

Package: chromium-sandbox
Pin: origin security.debian.org
Pin-Priority: 1000

Package: firefox
Pin: release o=Ubuntu
Pin-Priority: -1

Package: thunderbird
Pin: release o=Ubuntu
Pin-Priority: -1

Package: chromium-browser
Pin: release o=Ubuntu
Pin-Priority: -1' >> /etc/apt/preferences.d/nativeapt
echo 'Done'

# Create VNC configuration directory
mkdir -p ~/.vnc

# Create VNC password file (default 1234567890)
printf "1234567890" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Create VNC startup script
echo '#!/bin/sh
xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
export DISPLAY=:3
startxfce4' >> ~/.vnc/xstartup

# Create script for starting VNC server
echo '#!/bin/sh
export USER=portadesx
export HOME=/home/portadesx
vncserver -name remote-desktop -localhost no :3
echo 'VNC server address: 127.0.0.1:3'' >> /usr/local/bin/startvnc

# Create script for stopping VNC server
echo '#!/bin/sh
export USER=portadesx
export HOME=/home/portadesx
vncserver -kill :3
rm -rf /root/.vnc/localhost:3.pid
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1' >> /usr/local/bin/stopvnc

# Create script for restarting VNC server
echo '#!/bin/sh
vncstop
vncstart' >> /usr/local/bin/restartvnc

# Make it executable
cd /usr/local/bin
chmod +x startvnc
chmod +x stopvnc
chmod +x restartvnc
cd
chmod +x ~/.vnc/xstartup
