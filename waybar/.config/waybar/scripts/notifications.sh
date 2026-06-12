#!/bin/bash
# Notification count for swaync; outputs waybar JSON
COUNT=$(swaync-client -c 2>/dev/null || echo 0)
if [ "$COUNT" -gt 0 ]; then
    echo "{\"text\": \"󱅫 ${COUNT}\", \"tooltip\": \"${COUNT} notification(s)\", \"class\": \"has-notifications\"}"
else
    echo "{\"text\": \"󰂚\", \"tooltip\": \"No notifications\", \"class\": \"\"}"
fi
