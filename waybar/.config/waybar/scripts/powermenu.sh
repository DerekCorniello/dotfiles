#!/usr/bin/env bash
# Confirmation dialog for Waybar power button - fast path via hyprland-dialog.
# Usage: powermenu.sh [shutdown|reboot]
# Shows an "Are you sure?" popup before executing the action.
# Prioritizes hyprland-dialog (native Hyprtoolkit, ~50ms) over zenity (GTK, ~800ms+).

action="${1:-shutdown}"

case "$action" in
  shutdown)
    title="Shut Down"
    text="Are you sure you want to shut down?"
    cmd=(shutdown now)
    ;;
  reboot)
    title="Reboot"
    text="Are you sure you want to reboot?"
    cmd=(systemctl reboot)
    ;;
  poweroff)
    title="Shut Down"
    text="Are you sure you want to shut down?"
    cmd=(systemctl poweroff)
    ;;
  *)
    echo "Usage: $0 [shutdown|reboot]" >&2
    exit 1
    ;;
esac

# Fastest: hyprland-dialog (hyprland-guiutils 0.2.2, Hyprtoolkit)
# Prints clicked button label to stdout; window close = empty string.
if command -v hyprland-dialog >/dev/null 2>&1; then
  choice=$(hyprland-dialog --title "$title" --text "$text" --buttons "Yes;No" 2>/dev/null)
  if [ "$choice" = "Yes" ]; then
    exec "${cmd[@]}"
  fi
  exit 0
fi

# Fallback: vicinae dmenu (daemon, instant after first start)
if command -v vicinae >/dev/null 2>&1; then
  choice=$(printf "Yes\nNo" | vicinae dmenu -p "$text" -n "$title" 2>/dev/null)
  if [ "$choice" = "Yes" ]; then
    exec "${cmd[@]}"
  fi
  exit 0
fi

# Fallback: wofi --dmenu
if command -v wofi >/dev/null 2>&1; then
  choice=$(printf "Yes\nNo" | wofi --dmenu -p "$text" 2>/dev/null)
  if [ "$choice" = "Yes" ]; then
    exec "${cmd[@]}"
  fi
  exit 0
fi

# Last resort: zenity (slow GTK)
if command -v zenity >/dev/null 2>&1; then
  if zenity --question --title="$title" --text="$text" --width=320 --ok-label="Yes" --cancel-label="No" 2>/dev/null; then
    exec "${cmd[@]}"
  fi
fi
