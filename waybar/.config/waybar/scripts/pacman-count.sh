#!/usr/bin/env bash
# Shows the last known update count instantly (no blank/pop-in on waybar start),
# then recomputes in the background and signals waybar to refresh when done.
cache="$HOME/.cache/waybar-pacman-count"

[ -f "$cache" ] && cat "$cache" || echo 0

(
    count=$(( $(checkupdates 2>/dev/null | wc -l) + $(yay -Qua --quiet 2>/dev/null | wc -l) + $(flatpak remote-ls --updates 2>/dev/null | wc -l) ))
    echo "$count" > "$cache"
    pkill -SIGRTMIN+8 waybar 2>/dev/null
) &
disown
