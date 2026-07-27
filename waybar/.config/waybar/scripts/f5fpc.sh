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

case $1 in
--status)
  info=$(f5_info)
  if grep -qi "Connection Status:.*established" <<<"$info"; then
    fav=$(grep -iE "^Fav-Id:" <<<"$info" | head -1 | sed -E 's/.*Fav-Name:[[:space:]]*//')
    ip=$(grep -i "Tunnel Client IPv4 Address:" <<<"$info" | head -1 | sed -E 's/.*Address:[[:space:]]*//' | tr -d '[:space:]')
    server=$(grep -i "Tunnel Server IPv4 Address:" <<<"$info" | head -1 | sed -E 's/.*Address:[[:space:]]*//' | tr -d '[:space:]')

    tip="F5 VPN: connected"
    [ -n "$fav" ] && tip+=$'\n'"Favorite: $fav"
    [ -n "$ip" ] && tip+=$'\n'"Client IP: $ip"
    [ -n "$server" ] && tip+=$'\n'"Server IP: $server"

    jq -nc --arg tip "$tip" \
      '{"text":"connected","class":"connected","alt":"connected","tooltip":$tip}'
  else
    jq -nc '{"text":"stopped","class":"stopped","alt":"stopped","tooltip":"F5 VPN: not connected"}'
  fi
  ;;
--toggle)
  toggle_status
  ;;
esac
