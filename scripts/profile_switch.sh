#!/bin/bash

asusctl profile next
current_level=$(asusctl profile get | awk '/Active profile:/ {print $NF}')

notify-send -t 2000 -h string:x-canonical-private-synchronous:active-profile -i application-default "Profile Switch" "Current Level: $current_level"
