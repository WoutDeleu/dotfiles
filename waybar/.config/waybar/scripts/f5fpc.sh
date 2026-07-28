#!/usr/bin/env bash

# Waybar status module for the F5 SSL VPN client (f5fpc).
# Reports connected/stopped state and builds a tooltip with session details.

f5_info() {
  timeout 5 f5fpc --info 2>/dev/null
}

f5_connected() {
  f5_info | grep -qi "Connection Status:.*established"
}

toggle_status() {
  if f5_connected; then
    f5fpc --stop >/dev/null 2>&1
    notify-send -a "F5 VPN" "Disconnecting..."
  else
    notify-send -a "F5 VPN" "Not connected. Start f5fpc manually with your host/credentials."
  fi
}

# Toggle a floating popup window showing live f5fpc status, positioned just
# below the bar on the right edge (matching the btop popup style).
show_popup() {
  local title="waybar-f5"
  local win_w=760 win_h=460 bar_height=52

  if hyprctl clients -j | jq -e ".[] | select(.title == \"$title\")" >/dev/null 2>&1; then
    hyprctl dispatch closewindow "title:$title"
    return 0
  fi

  local screen_w pos_x pos_y
  screen_w=$(hyprctl monitors -j | jq '.[0].width')
  pos_x=$((screen_w - win_w - 12))
  pos_y=$bar_height

  kitty \
    --title "$title" \
    --override "initial_window_width=${win_w}" \
    --override "initial_window_height=${win_h}" \
    sh -c 'if command -v watch >/dev/null 2>&1; then exec watch -t -n 2 "f5fpc --info || echo \"f5fpc (VRT): not connected\""; fi; f5fpc --info || echo "f5fpc (VRT): not connected"; echo; read -n1 -s -r -p "Press any key to close..."' &

  for _ in $(seq 1 20); do
    sleep 0.1
    if hyprctl clients -j | jq -e ".[] | select(.title == \"$title\")" >/dev/null 2>&1; then
      hyprctl dispatch setfloating "title:$title"
      hyprctl dispatch movewindowpixel "exact ${pos_x} ${pos_y}" "title:$title"
      break
    fi
  done
}

case $1 in
--status)
  info=$(f5_info)
  if grep -qi "Connection Status:.*established" <<<"$info"; then
    fav=$(grep -iE "^Fav-Id:" <<<"$info" | head -1 | sed -E 's/.*Fav-Name:[[:space:]]*//')
    ip=$(grep -i "Tunnel Client IPv4 Address:" <<<"$info" | head -1 | sed -E 's/.*Address:[[:space:]]*//' | tr -d '[:space:]')
    server=$(grep -i "Tunnel Server IPv4 Address:" <<<"$info" | head -1 | sed -E 's/.*Address:[[:space:]]*//' | tr -d '[:space:]')

    tip="f5fpc (VRT): connected"
    [ -n "$fav" ] && tip+=$'\n'"Favorite: $fav"
    [ -n "$ip" ] && tip+=$'\n'"Client IP: $ip"
    [ -n "$server" ] && tip+=$'\n'"Server IP: $server"

    jq -nc --arg tip "$tip" \
      '{"text":"connected","class":"connected","alt":"connected","tooltip":$tip}'
  else
    jq -nc '{"text":"","class":"stopped","alt":"stopped","tooltip":"f5fpc (VRT): not connected"}'
  fi
  ;;
--toggle)
  toggle_status
  ;;
--popup)
  show_popup
  ;;
esac
