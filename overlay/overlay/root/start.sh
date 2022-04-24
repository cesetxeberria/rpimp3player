#!/bin/sh
#sudo loadkeys <<EOF
#keycode 200 = bracketleft
#keycode 201 = bracketright
#keycode 165 = bracketright
#keycode 163 = bracketleft
#EOF
  modprobe snd-bcm2835
  mkdir -p /media/musika
  mount /dev/sda1 /media/musika -o ro
  find /media/musika/ -name "*.mp3" > /tmp/lista.m3u 
  mpg123 -@ /tmp/lista.m3u
