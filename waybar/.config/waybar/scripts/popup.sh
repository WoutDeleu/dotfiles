#!/bin/bash
# Central popup dispatcher — ensures only one bar popup is open at a time.
# Usage: popup.sh <btop|swaync|weather>

BTOP_TITLE="waybar-btop"
WEATHER_TITLE="waybar-weather"

close_btop() {
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$BTOP_TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch 'hl.dsp.window.close({window="title:'"$BTOP_TITLE"'"})'
        return 0  # was open
    fi
    return 1  # was not open
}

close_swaync() {
    if swaync-client --get-visibility 2>/dev/null | grep -q "true"; then
        swaync-client -t
        return 0  # was open
    fi
    return 1  # was not open
}

close_weather() {
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$WEATHER_TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch 'hl.dsp.window.close({window="title:'"$WEATHER_TITLE"'"})'
        return 0  # was open
    fi
    return 1  # was not open
}

case "$1" in
    btop)
        close_swaync
        close_weather
        if ! close_btop; then
            ~/.config/waybar/scripts/btop-popup.sh --open
        fi
        ;;
    swaync)
        close_btop
        close_weather
        swaync-client -t
        ;;
    weather)
        close_btop
        close_swaync
        if ! close_weather; then
            ~/.config/waybar/scripts/weather-popup.sh --open
        fi
        ;;
    *)
        echo "Usage: popup.sh <btop|swaync|weather>"
        exit 1
        ;;
esac
