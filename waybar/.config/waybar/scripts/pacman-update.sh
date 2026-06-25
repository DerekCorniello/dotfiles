#!/usr/bin/env sh
# Launcher for the Waybar update button. Opens kitty on the *currently active*
# workspace. This Hyprland uses a Lua config, so `hyprctl dispatch` evaluates
# its argument as Lua (hl.dsp.exec_cmd) rather than the classic bracket syntax.
ws=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl dispatch "hl.dsp.exec_cmd('[workspace $ws] kitty $HOME/.config/waybar/scripts/system-update.sh')"
