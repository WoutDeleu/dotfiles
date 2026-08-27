#!/bin/bash
# Open (or toggle) a floating btop window positioned just below the performance icon.
# Called directly: toggles. Called with --open: always opens (dispatcher already closed it).

TITLE="waybar-btop"
WIN_W=900
WIN_H=550
BAR_HEIGHT=52  # bar height (40) + margin-top (6) + padding (~6)

# Toggle when called directly (no args)
if [[ "$1" != "--open" ]]; then
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch 'hl.dsp.window.close({window="title:'"$TITLE"'"})'
        exit 0
    fi
fi

# Position flush to the right edge, just below the bar (under the icon)
SCREEN_W=$(hyprctl monitors -j | jq '.[0].width')
POS_X=$((SCREEN_W - WIN_W - 12))  # 12px matches bar margin-right
POS_Y=$BAR_HEIGHT

kitty \
    --title "$TITLE" \
    --override "initial_window_width=${WIN_W}" \
    --override "initial_window_height=${WIN_H}" \
    btop &

# Wait for the window to appear, then float + position it
for i in $(seq 1 20); do
    sleep 0.1
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$TITLE\")" > /dev/null 2>&1; then
        hyprctl dispatch 'hl.dsp.window.float({action="on", window="title:'"$TITLE"'"})'
        hyprctl dispatch 'hl.dsp.window.move({x='"${POS_X}"', y='"${POS_Y}"', window="title:'"$TITLE"'"})'
        break
    fi
done
