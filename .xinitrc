#!/bin/sh
mpd /home/phil/.mpd/config
xmodmap .xmodmaprc &
dropboxd &
feh --bg-scale /home/phil/doc/pic/the_void_02.jpg &
xcompmgr &
exec xmonad
