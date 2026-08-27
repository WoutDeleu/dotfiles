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
# NOTE: config is Lua now, so `hyprctl dispatch` args are evaluated as Lua
# (return hl.dispatch(<arg>)). Use hl.dsp.* dispatchers, not legacy strings.
hyprctl dispatch 'hl.dsp.focus({workspace=8})'
sleep 0.3

# Launch apps on their workspaces (silent = don't switch focus)
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 1 silent] kitty")'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 5 silent] zapzap")'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 6 silent] kitty -e aerc")'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 7 silent] /opt/helium-browser-bin/helium-wrapper --profile-directory=Default --app-id=kjbdgfilnfhdoflbpgamdcdgpehopbep")'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 8 silent] kitty -e spotify_player")'

sleep 0.3
hyprctl dispatch 'hl.dsp.focus({workspace=1})'
