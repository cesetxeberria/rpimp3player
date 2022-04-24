# rpimp3player
Buildroot configuration to turn a raspberry pi into a dumb mp3 player

# steps
Clone buildroot's git repository,load rpi's config file and modify it
```
git clone https://github.com/buildroot/buildroot
cd buildroot
make raspberrypi_defconfig
make menuconfig
```

Select configuration options. 
```
Toolchain -- > enable WCHAR support
System configuration --> root filesystem overlay directories (overlay)
Target packages --> audio and video --> alsa-utils
Target packages --> audio and video --> mpg123
Target packages --> filesystem and flash utilities --> exfatprogs
Target packages --> filesystem and flash utilities --> ntfs-3g
Filesystem images --> initial RAM filesystem linked into linux kernel
```

Create a folder named "overlay" with our customizations. This file sets the headphones as default audio output.

>/etc/asound.conf
```
defaults.pcm.card 1
defaults.ctl.card 1
```

This script loads the soundcard module, mounts the pendrive, creates a playlist and starts playing.
>/root/start.sh
```
modprobe snd-bcm2835
mkdir -p /media/musika
mount /dev/sda1 /media/musika -o ro
find /media/musika/ -name "*.mp3" > /tmp/lista.m3u 
mpg123 -@ /tmp/lista.m3u
```

This file is a copy of the original inittab, but replaces the login console with the previous script.
>/etc/inittab
```
...
#tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console
tty1::respawn:-/bin/sh /root/start.sh
...
```
Soundcard is disabled by default so we have to enable it. Add a line at the end of file.
>board/raspberrypi/config_default.txt
```
...
dtparam=audio=on
...
```

I want to run the system in ram, so uncomment this line too.
>board/raspberrypi/config_default.txt
```
...
#initramfs rootfs.cpio.gz
initramfs rootfs.cpio.gz
...
```
Modify this file to add rootfs.cpio.gz to our image, and change the size to 64M (original is 32M).
>board/raspberrypi/genimage-raspberrypi.cfg
```
image boot.vfat {
        vfat {
                files = {
                        "bcm2708-rpi-b.dtb",
                        "bcm2708-rpi-b-plus.dtb",
                        "bcm2708-rpi-cm.dtb",
                        "rpi-firmware/bootcode.bin",
                        "rpi-firmware/cmdline.txt",
                        "rpi-firmware/config.txt",
                        "rpi-firmware/fixup.dat",
                        "rpi-firmware/start.elf",
                        "rootfs.cpio.gz",
                        "zImage"
                }
        }

        size = 64M
}
...
```
Run the project
```
make
```

Special thanks to
https://marcocetica.com/posts/buildroot-tutorial/
https://agentoss.wordpress.com/2011/03/02/how-to-build-a-tiny-linux-mp3-player-system-using-buildroot/
