#!/bin/sh
# Install x11 and tur repo
termux-setup-storage
apt update
apt install x11-repo tur-repo
apt update

# Update installed package but keep configuration
apt upgrade -y -o Dpkg::Options::="--force-confold"

# Install depedency
apt install curl wget nano proot-distro termux-x11 pulseaudio vulkan-loader-android mesa-zink virglrenderer-mesa-zink -y

# Create manual proot-distro configuration
cat <<EOF > $PREFIX/etc/proot-distro/portadesx.sh
DISTRO_NAME="PortadesX"
TARBALL_URL['aarch64']="https://github.com/arfshl/portadesx-testing/releases/download/v24.04-202508020443-beta/portadesk-2404.tar.xz"
TARBALL_SHA256['aarch64']="bf25ffb45a609e35b192ae24621049310a43d521777311339211245687e3ff2b"
distro_setup() {
        run_proot_cmd mkdir /home/portadesx/android_files
        run_proot_cmd ln -s /storage/emulated/0/ /home/portadesx/android_files
}
EOF

# Create startup script
# for CLI session
printf 'proot-distro login portadesx --user portadesx' >> /data/data/com.termux/files/usr/bin/portadesx-cli

# for X11 session
cat <<EOF > /data/data/com.termux/files/usr/bin/portadesx-x11
#!/bin/sh
LD_PRELOAD=/system/lib64/libskcodec.so
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
export XDG_RUNTIME_DIR=${TMPDIR}
kill -9 \$(pgrep -f "termux.x11")\ 2>/dev/null
kill -9 \$(pgrep -f "virgl")\ 2>/dev/null
virgl_test_server_android &
termux-x11 :0 >/dev/null &
proot-distro login portadesx --shared-tmp -- /bin/sh -c 'export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && su - portadesx -c "DISPLAY=:0 GALLIUM_DRIVER=virpipe startxfce4"'
EOF

# Make all of them executable
chmod +x /data/data/com.termux/files/usr/bin/portadesx-x11
chmod +x /data/data/com.termux/files/usr/bin/portadesx-cli

# Install rootfs
proot-distro install portadesx





