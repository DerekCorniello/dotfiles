#!/bin/bash

# switch profile and get the new current level
asusctl profile -n
current_level=$(asusctl profile -p | awk '/Active profile is/ {print $NF}')

# send a notification with the current level
notify-send -t 2000 -h string:x-canonical-private-synchronous:active-profile -i application-default "Profile Switch" "Current Level: $current_level"
