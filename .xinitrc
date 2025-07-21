#!/bin/sh

## reload pywal theme ##
wal -n -R
dwmc reloadxrdb
setroot --on 0 $HOME/.wallpapers/current_wallpaper --on 1 $HOME/.wallpapers/current_wallpaper &

## setkeyboard ##
setxkbmap pt &

## numblock enable ##
numlockx &

## Toutchpad configuration ##
xinput set-prop "PNP0C50:0e 06CB:7E7E Touchpad" "libinput Natural Scrolling Enabled" 1 &
xinput set-prop "PNP0C50:0e 06CB:7E7E Touchpad" "libinput Tapping Enabled" 1 &

## run applications ##
pipewire & 
syncthing --no-browser &
picom &
exec /usr/libexec/polkit-gnome-authentication-agent-1 &

## blue light and brightness gammastep ##
gammastep &

## Music Player Daemon ##
mpd &

## autolock and suspend ##
# (lock and suspend can be set in the same command -> "slock & loginctl suspend")
xautolock -time 15 -locker "slock" -notify 180 -notifier "dunstify 'Locking system in 3 minutes!!'"  &
#xautolock -time 20 -locker "loginctl suspend" &

exec dbus-run-session dwm
