#!/usr/bin/env bash
# Roku-only workspace layout for Hyprland.
# Single-shot (no socat loop). Triggered from Lua via hl.on("monitor.added/removed")
# and hl.on("hyprland.start"). See lua/roku-workspaces.lua.
#
# Behavior:
# - Roku TV present on HDMI-A-1 (desc "RKU Roku TV") -> move all open normal
#   workspaces to HDMI-A-1. No focus changes.
# - DP-1/DP-3 present (office dock, unchanged legacy behavior) -> 1 -> eDP-1, 2 -> DP.
# - Anything else (other HDMI, laptop only, Roku unplugged) -> no-op.
#   Hyprland already moves workspaces to the remaining monitor on unplug,
#   so doing nothing IS the default behavior the user asked for.
set -uo pipefail

ROKU_PORT="HDMI-A-1"
ROKU_DESC="RKU Roku TV"
LAPTOP="eDP-1"
LOCK="/tmp/roku-layout.lock"
LOG="/tmp/roku-layout.log"

# Prevent overlapping runs from added+removed+layout_changed storms.
exec 200>"$LOCK"
flock -n 200 || exit 0

log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "${1:-run}" "$2" >>"$LOG"; }

is_roku_present() {
  hyprctl monitors -j 2>/dev/null | jq -e \
    --arg port "$ROKU_PORT" --arg desc "$ROKU_DESC" \
    'map(select(.name == $port and (.description // "" | contains($desc)))) | length > 0' \
    >/dev/null 2>&1
}

# Normal (non-special) workspace ids only. Special workspaces have negative ids
# and must not be passed to workspace.move.
list_workspaces() {
  hyprctl workspaces -j 2>/dev/null | jq -r '.[] | select(.id > 0) | .id' | sort -n -u
}

# NOTE: Hyprland 0.55+ Lua syntax. Old hyprlang
# `hyprctl dispatch moveworkspacetomonitor 1 HDMI-A-1` now errors with
# "expected a dispatcher (e.g. hl.dsp.window.close())" and silently did
# nothing (exit 7). New form: hl.dsp.workspace.move({workspace=.., monitor=..}).
move_ws_to_mon() {
  hyprctl dispatch "hl.dsp.workspace.move({workspace=$1, monitor=\"$2\"})" 2>&1 || true
}

apply_roku_layout() {
  local ws
  for ws in $(list_workspaces); do
    move_ws_to_mon "$ws" "$ROKU_PORT"
  done
}

apply_dp_layout() {
  local dp
  dp=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | grep -E 'DP-1|DP-3' | head -n1)
  [ -n "${dp:-}" ] || return 0
  move_ws_to_mon 1 "$LAPTOP"
  move_ws_to_mon 2 "$dp"
}

main() {
  local reason="${1:-manual}"
  if is_roku_present; then
    log "$reason" "Roku present -> applying Roku layout"
    apply_roku_layout
    return 0
  fi
  if hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | grep -Eq 'DP-1|DP-3'; then
    log "$reason" "Roku absent, DP dock present -> applying DP layout"
    apply_dp_layout
    return 0
  fi
  log "$reason" "Roku absent, no DP dock -> no-op (default Hyprland behavior)"
}

main "$@"
