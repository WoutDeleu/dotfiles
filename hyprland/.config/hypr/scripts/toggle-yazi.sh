#!/bin/bash
if hyprctl clients -j | jq -e '.[] | select(.class == "yazi-float")' > /dev/null 2>&1; then
    hyprctl dispatch 'hl.dsp.focus({window="class:yazi-float"})'
else
    hyprctl dispatch 'hl.dsp.exec_cmd("[float; center] kitty --class yazi-float -e yazi")'
fi
