#!/bin/sh
# Create VNC configuration directory
mkdir -p ~/.vnc

# Create VNC password file (default 1234567890)
printf "1234567890" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Create VNC startup script
echo '#!/bin/sh
xrdb $HOME/.Xresources
export PULSE_SERVER=127.0.0.1
DISPLAY=:0 GALLIUM_DRIVER=virpipe startxfce4' >> ~/.vnc/xstartup

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
chmod +x vncstart
chmod +x vncstop
chmod +x vncrestart
cd
chmod +x ~/.vnc/xstartup
