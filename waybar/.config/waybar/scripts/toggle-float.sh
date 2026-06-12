#!/usr/bin/env bash
# Usage: toggle-float.sh <wm-class> <launch-command...>
# Toggles a floating terminal window — kills it if running, launches it if not.

CLASS="$1"
shift

if hyprctl clients -j | python3 -c "
import sys, json
clients = json.load(sys.stdin)
found = any(c['class'] == '$CLASS' for c in clients)
sys.exit(0 if found else 1)
"; then
    hyprctl dispatch closewindow "class:^(${CLASS})$"
else
    "$@"
fi
