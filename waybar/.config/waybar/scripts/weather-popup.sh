#!/bin/bash
# Toggle a floating weather window centered just below the bar.

TITLE="waybar-weather"
WIN_H=620
BAR_HEIGHT=52  # bar height (40) + margin-top (6) + padding (~6)

if [[ "$1" != "--open" ]]; then
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch closewindow "title:$TITLE"
        exit 0
    fi
fi

SCREEN_W=$(hyprctl monitors -j | jq '.[0].width')

kitty \
    --title "$TITLE" \
    --override "initial_window_height=${WIN_H}" \
    bash -c 'curl -s "wttr.in?format=v2" 2>/dev/null || curl -s "wttr.in" 2>/dev/null; echo; read -p "Press Enter to close..."' &

for i in $(seq 1 20); do
    sleep 0.1
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch setfloating "title:$TITLE"
        # Read actual window width after it appears, then center it
        WIN_W=$(hyprctl clients -j | jq ".[] | select(.title == \"$TITLE\") | .size[0]")
        POS_X=$(( (SCREEN_W - WIN_W) / 2 ))
        hyprctl dispatch movewindowpixel "exact ${POS_X} ${BAR_HEIGHT}" "title:$TITLE"
        break
    fi
done
