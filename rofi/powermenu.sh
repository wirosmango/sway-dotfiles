#!/bin/env bash

# Options for powermenu
lock="    Lock"
logout="    Logout"
shutdown="    Shutdown"
reboot="   Reboot"

# Get answer from user via rofi
selected_option=$(echo "$lock
$logout
$reboot
$shutdown" | rofi -dmenu\
                  -i\
                  -p "Powermenu"\
                  -config "~/.config/rofi/config.rasi"\
                  -font "JetBrains Mono Regular 12"\
                  -width "15"\
                  -lines 5\
                  -line-margin 3\
                  -line-padding 10\
                  -scrollbar-width "0" )

# Do something based on selected option
if [ "$selected_option" == "$lock" ]
then
    exec swaylock -f
elif [ "$selected_option" == "$logout" ]
then
    loginctl terminate-user `whoami`
elif [ "$selected_option" == "$shutdown" ]
then
    systemctl poweroff
elif [ "$selected_option" == "$reboot" ]
then
    systemctl reboot
else
    echo "No match"
fi
