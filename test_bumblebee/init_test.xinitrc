#!/bin/bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/Xresources
sysmodmap=/etc/X11/xinit/Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

# export LD_PRELOAD=/usr/lib64/.so

# optirun64 glxgears
#/usr/bin/uxterm
# vglrun -ld /usr/lib/ -d :1 /usr/bin/uxterm -bg grey -fn 7x14 -maximized
vglrun -ld /usr/lib64/ -c xv -d :1  glxgears