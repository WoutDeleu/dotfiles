#!/usr/bin/env bash
# Usage: toggle-float.sh <wm-class> <launch-command...>
# Toggles a floating terminal window — kills it if running, launches it if not.
# Only one float window can be open at a time — others are closed on launch.

FLOAT_CLASSES=("btop-float" "pulsemixer-float" "impala-float" "bluetui-float", "tsui-float")

CLASS="$1"
shift

if hyprctl clients -j | python3 -c "
import sys, json
clients = json.load(sys.stdin)
found = any(c['class'] == '$CLASS' for c in clients)
sys.exit(0 if found else 1)
"; then
    hyprctl dispatch 'hl.dsp.window.close({window="class:^('"${CLASS}"')$"})'
else
    # Close all other known float windows first
    for other in "${FLOAT_CLASSES[@]}"; do
        [[ "$other" == "$CLASS" ]] && continue
        hyprctl dispatch 'hl.dsp.window.close({window="class:^('"${other}"')$"})' 2>/dev/null
    done
    "$@"
fi
