#!/bin/bash
# Start hypridle with the appropriate profile (AC vs battery)
# Re-run on power state change by calling: pkill hypridle && start-hypridle.sh

IDLE_CONF="$HOME/.config/hypr/hypridle.conf"
BATTERY_CONF="$HOME/.config/hypr/hypridle-battery.conf"

# Kill existing hypridle instance if running
pkill -x hypridle 2>/dev/null
sleep 0.5

# Check if any AC adapter is online
on_ac() {
    for ac in /sys/class/power_supply/*/online; do
        [[ -f "$ac" ]] && [[ "$(cat "$ac")" == "1" ]] && return 0
    done
    return 1
}

if on_ac; then
    exec hypridle -c "$IDLE_CONF"
else
    exec hypridle -c "$BATTERY_CONF"
fi
