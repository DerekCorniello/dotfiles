#!/usr/bin/env bash
# Shows the last known update count instantly (no blank/pop-in on waybar start),
# then recomputes in the background and signals waybar ONLY when the count
# actually changed.
#
# Previously this signaled waybar unconditionally on every run. Because the
# module is wired to `signal: 8`, that SIGRTMIN+8 made waybar re-run this exec,
# which recomputed and signaled again -> a runaway loop that hammered the AUR
# (`yay -Qua`) and Flathub (`flatpak remote-ls`) every few seconds, producing
# HTTP 429s and a constantly flashing count. The change-guard breaks the loop
# (no change -> no signal), and the flock prevents concurrent recomputes from
# piling up if a signal does arrive mid-run.
cache="$HOME/.cache/waybar-pacman-count"
lock="$HOME/.cache/waybar-pacman-count.lock"

# Print the cached value immediately so waybar never blocks on the network.
[ -f "$cache" ] && cat "$cache" || echo 0

# Recompute in the background; only re-render waybar if the number changed.
(
    exec 9>"$lock"
    flock -n 9 || exit 0   # a recompute is already in flight; skip this one

    count=$(( $(checkupdates 2>/dev/null | wc -l) + $(yay -Qua --quiet 2>/dev/null | wc -l) + $(flatpak remote-ls --updates 2>/dev/null | wc -l) ))

    old=$(cat "$cache" 2>/dev/null)
    if [ "$count" != "$old" ]; then
        echo "$count" > "$cache"
        pkill -SIGRTMIN+8 waybar 2>/dev/null
    fi
) &
disown
