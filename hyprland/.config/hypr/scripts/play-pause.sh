#!/bin/bash
# Checks if the active player is playing, forces a pause, otherwise plays it.
if [[ $(playerctl status) == "Playing" ]]; then
    playerctl --all-players pause
else
    playerctl play
fi
