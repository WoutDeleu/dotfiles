#!/usr/bin/env bash
# Outputs a volume bar with icon for waybar, percentage on hover

get_icon() {
    local vol=$1 muted=$2
    if [[ "$muted" == "yes" ]]; then echo "󰝟"; return; fi
    if   (( vol == 0 ));  then echo "󰕿"
    elif (( vol < 50 ));  then echo "󰖀"
    else                       echo "󰕾"
    fi
}

make_bar() {
    local vol=$1
    local total=10
    local filled=$(( vol * total / 100 ))
    local bar=""
    for (( i=0; i<total; i++ )); do
        if (( i < filled )); then bar+="█"
        else bar+="░"
        fi
    done
    echo "$bar"
}

raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
# e.g. "Volume: 0.65" or "Volume: 0.65 [MUTED]"
vol_float=$(echo "$raw" | awk '{print $2}')
muted=$(echo "$raw" | grep -q "MUTED" && echo "yes" || echo "no")
vol=$(awk "BEGIN {printf \"%d\", $vol_float * 100}")

icon=$(get_icon "$vol" "$muted")
bar=$(make_bar "$vol")

if [[ "$muted" == "yes" ]]; then
    text="<span size='large' color='#6c7086'>${icon}</span><span color='#6c7086'>  ${bar}</span>"
else
    text="<span size='large'>${icon}</span>  <span color='#cba6f7'>${bar}</span>"
fi

printf '{"text": "%s", "tooltip": "%s%%", "class": "%s"}\n' \
    "$text" "$vol" "$([ "$muted" = "yes" ] && echo muted)"
