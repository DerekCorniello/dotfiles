#!/bin/bash
# Watches asusd's PlatformProfile D-Bus property (xyz.ljones.Asusd) and reacts
# to ANY profile change, regardless of trigger. This is needed because the
# fan/profile hotkey is handled entirely inside asusd via a D-Bus method call
# (NextPlatformProfile) - it never reaches Hyprland as a key event, so a
# Hyprland keybind can't notice it or fire a notification on its own.
#
# On every change it:
#   1. Shows a notification with the new profile name.
#   2. Persists the new profile into asusd's AC or Battery slot (whichever
#      power source is currently active), so the manual choice survives
#      plugging/unplugging instead of being overwritten by
#      platform_profile_on_ac/battery in /etc/asusd/asusd.ron.

ac_path=$(grep -l Mains /sys/class/power_supply/*/type 2>/dev/null | head -1)
ac_path=${ac_path%/type}

last_value=""

dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/xyz/ljones'" |
while read -r line; do
  [[ "$line" == *'string "PlatformProfile"'* ]] || continue

  read -r value_line
  value=$(grep -oP 'uint32\s+\K[0-9]+' <<<"$value_line")
  [[ -z "$value" || "$value" == "$last_value" ]] && continue
  last_value="$value"

  profile=$(asusctl profile get | awk '/Active profile:/ {print $NF}')
  [[ -z "$profile" ]] && continue

  if [[ -n "$ac_path" && "$(cat "$ac_path/online" 2>/dev/null)" == "1" ]]; then
    asusctl profile set -a "$profile" >/dev/null
  else
    asusctl profile set -b "$profile" >/dev/null
  fi

  notify-send "Profile Switch" -t 2000 -h string:x-canonical-private-synchronous:active-profile -i application-default "Current Level: $profile"
done
