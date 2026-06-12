#!/bin/bash
# Cava audio visualizer for waybar — only visible while playing

CONFIG="$HOME/.config/waybar/cava.conf"
CHARS=(' ' '▁' '▂' '▃' '▄' '▅' '▆' '▇')

cava -p "$CONFIG" | while IFS=';' read -ra BARS; do
    if playerctl -l 2>/dev/null | xargs -I{} playerctl -p {} status 2>/dev/null | grep -q "^Playing$"; then
        output=""
        for val in "${BARS[@]}"; do
            [[ "$val" =~ ^[0-7]$ ]] && output+="${CHARS[$val]}"
        done
        [[ -n "$output" ]] && echo "$output"
    else
        echo ""
    fi
done
