#!/bin/bash
if hyprctl clients -j | jq -e '.[] | select(.class == "yazi-float")' > /dev/null 2>&1; then
    hyprctl dispatch focuswindow class:yazi-float
else
    hyprctl dispatch exec "[float; center] kitty --class yazi-float -e yazi"
fi
