#!/usr/bin/env bash
# Prints the number of available package updates.
#
# Called from waybar (no args):         prints cached count, instant.
# Called from systemd timer (--wait):   recomputes, updates cache, signals waybar.
# Called from system-update.sh (--wait):same.
#
# The systemd timer (pacman-update-check.timer) ensures the cache stays fresh
# every 30 min and keeps both monitor instances in sync — only one writer.
cache="$HOME/.cache/waybar-pacman-count"

_get_count() {
    echo $(( $(checkupdates 2>/dev/null | wc -l) + $(yay -Qua --quiet 2>/dev/null | wc -l) + $(flatpak remote-ls --updates 2>/dev/null | wc -l) ))
}

if [ "${1:-}" = "--wait" ]; then
    count=$(_get_count)
    printf "%d" "$count" > "$cache"
    pkill -SIGRTMIN+8 waybar 2>/dev/null
    echo "$count"
    exit 0
fi

[ -f "$cache" ] && cat "$cache" || echo 0
