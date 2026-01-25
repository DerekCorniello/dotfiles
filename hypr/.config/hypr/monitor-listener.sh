#!/usr/bin/env bash
set -euo pipefail

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

get_workspaces() {
  hyprctl workspaces -j | jq -r '.[].id'
}

apply_layout() {
  local monitors
  monitors=$(hyprctl monitors -j | jq -r '.[].name')

  local workspaces
  workspaces=$(get_workspaces)

  # =========================
  # HDMI plugged
  # =========================
  if echo "$monitors" | grep -qx "HDMI-A-1"; then
    for ws in $workspaces; do
      if [ "$ws" -eq 10 ]; then
        hyprctl dispatch moveworkspacetomonitor 1 HDMI-A-1
        hyprctl dispatch moveworkspacetomonitor 10 eDP-1 >/dev/null
      else
        hyprctl dispatch moveworkspacetomonitor "$ws" HDMI-A-1 >/dev/null
      fi
    done

    # Set defaults explicitly
    hyprctl dispatch focusmonitor HDMI-A-1 >/dev/null
    hyprctl dispatch workspace 1 >/dev/null

    hyprctl dispatch focusmonitor eDP-1 >/dev/null
    hyprctl dispatch workspace 10 >/dev/null

    return
  fi

  # =========================
  # DP plugged
  # =========================
  if echo "$monitors" | grep -Eq "DP-1|DP-3"; then
    local dp
    dp=$(echo "$monitors" | grep -E "DP-1|DP-3" | head -n1)

    hyprctl dispatch moveworkspacetomonitor 1 eDP-1 >/dev/null
    hyprctl dispatch moveworkspacetomonitor 2 "$dp" >/dev/null

    hyprctl dispatch focusmonitor eDP-1 >/dev/null
    hyprctl dispatch workspace 1 >/dev/null
    return
  fi

  # =========================
  # Laptop only
  # =========================
  for ws in $workspaces; do
    hyprctl dispatch moveworkspacetomonitor "$ws" eDP-1 >/dev/null
  done

  hyprctl dispatch focusmonitor eDP-1 >/dev/null
  hyprctl dispatch workspace 10 >/dev/null
}

# Initial application
sleep 0.3
apply_layout

# Listen for monitor changes only
socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*)
      sleep 0.3
      apply_layout
      ;;
  esac
done
