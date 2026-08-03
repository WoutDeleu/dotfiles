#!/bin/bash

# Wait for Hyprland to be ready
until hyprctl monitors &>/dev/null; do
    sleep 0.5
done

sleep 1

# Dynamic per-monitor workspace assignment (adapts to home/work monitors).
# Start the watcher and give it a moment to place workspaces before apps launch.
~/.config/hypr/monitors/monitor-workspaces.sh watch &
sleep 1

# Switch to ws 8 first, then settle on ws 2
hyprctl dispatch workspace 8
sleep 0.3

# Launch apps on their workspaces (silent = don't switch focus)
hyprctl dispatch exec "[workspace 1 silent] kitty"
hyprctl dispatch exec "[workspace 5 silent] zapzap"
hyprctl dispatch exec "[workspace 6 silent] kitty -e aerc"
hyprctl dispatch exec "[workspace 7 silent] /opt/helium-browser-bin/helium-wrapper --profile-directory=Default --app-id=kjbdgfilnfhdoflbpgamdcdgpehopbep"
hyprctl dispatch exec "[workspace 8 silent] kitty -e spotify_player"

sleep 0.3
hyprctl dispatch workspace 1
