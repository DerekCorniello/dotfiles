#!/bin/bash
throttle_ms=25
lockfile="/tmp/waybar-scroll-throttle.lock"

now=$(date +%s%N)
if [ -f "$lockfile" ]; then
  last=$(cat "$lockfile")
  elapsed=$(( (now - last) / 1000000 ))
  if [ "$elapsed" -lt "$throttle_ms" ]; then
    exit 0
  fi
fi

echo "$now" > "$lockfile"
exec "$@"
