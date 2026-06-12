#!/bin/bash
PID_FILE="$HOME/.cache/waybar-ycal/popup.pid"
POPUP="$HOME/.config/waybar/scripts/ycal-popup.py"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill -SIGUSR1 "$PID"
        exit 0
    fi
fi

python3 "$POPUP" &
