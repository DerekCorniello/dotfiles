#!/bin/bash
# Get the current keyboard brightness level
current_level=$(asusctl -k | awk -F': ' '/Current keyboard led brightness/ {print $2}')

# Define available brightness levels in order (matching exact output)
brightness_levels=("Off" "Low" "Med" "High")

# Function to get index of current level
get_index() {
    for i in "${!brightness_levels[@]}"; do
        if [[ "${brightness_levels[$i]}" == "$1" ]]; then
            echo $i
            return
        fi
    done
    echo -1  # Return -1 if not found
}

# Get the index of the current level
current_index=$(get_index "$current_level")

# Handle argument (up/down)
if [[ "$1" == "up" ]]; then
    if [[ "$current_index" -lt $((${#brightness_levels[@]} - 1)) ]]; then
        asusctl -n  # Increase brightness only if not at max
        notify-send -t 2000 -h string:x-canonical-private-synchronous:keyboard-brightness -i application-default "Keyboard Brightness Updated" "Brightness Up"
    fi
elif [[ "$1" == "down" ]]; then
    if [[ "$current_index" -gt 0 ]]; then
        asusctl -p  # Decrease brightness only if not at off
        notify-send -t 2000 -h string:x-canonical-private-synchronous:keyboard-brightness -i application-default "Keyboard Brightness Updated" "Brightness Down"
    fi
else
    exit 1
fi
