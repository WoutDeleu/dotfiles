#!/usr/bin/env bash

tailscale_status() {
  tailscale status --json | jq -e '.BackendState == "Running"' >/dev/null
}

toggle_status() {
  if tailscale_status; then
    tailscale down
  else
    tailscale up
  fi
  sleep 3
}

case $1 in
--status)
  if tailscale_status; then
    T="green"
    F="red"
    I="none"
    colors=()

    for arg in "${@:2}"; do
      arg_lower=$(echo "$arg" | tr '[:upper:]' '[:lower:]' | tr -d '\n')

      case "$arg_lower" in
      ipv4 | ipv6)
        I="$arg_lower"
        ;;
      *)
        if [[ -n "$arg" ]]; then
          colors+=("$arg")
        fi
        ;;
      esac
    done

    if [ ${#colors[@]} -ge 1 ]; then T="${colors[0]}"; fi
    if [ ${#colors[@]} -ge 2 ]; then F="${colors[1]}"; fi

    status_json=$(tailscale status --json)

    tailnet=$(tailscale switch --list --json | jq -r '
    .[] | select(.selected == true) | .tailnet')

    case "$I" in
    ipv4) ip_index="0" ;;
    ipv6) ip_index="-1" ;;
    *) ip_index="" ;;
    esac

    if [[ -n "$ip_index" ]]; then
      peers=$(jq -r --arg T "$T" --arg F "$F" --arg Index "$ip_index" '
                    .Peer[]? | 
                    "<span color=\"" + (if .Online then $T else $F end) + "\">" + 
                    (.DNSName | split(".")[0]) + ": (" + .TailscaleIPs[$Index|tonumber] + ")</span>"
                ' <<<"$status_json")
      self=$(jq -r ' "<span>" + (.Self.DNSName | split(".")[0]) + ": ("+ .Self.TailscaleIPs[0] + ")</span>"
                ' <<<"$status_json")
    else
      peers=$(jq -r --arg T "$T" --arg F "$F" '
                    .Peer[]? | 
                    "<span color=\"" + (if .Online then $T else $F end) + "\">" +
                    (.DNSName | split(".")[0]) + "</span>"
                ' <<<"$status_json")
      self=$(jq -r ' "<span>" + (.Self.DNSName | split(".")[0]) + "</span>"
                ' <<<"$status_json")
    fi

    exitnode=$(jq -r '.Peer[]? | select(.ExitNode == true).DNSName | split(".")[0]' <<<"$status_json")

    jq -nc --arg txt " exit-node: ${exitnode:-none}" --arg tip "Tailscale"$'\n'"Tailnet: ""$tailnet"$'\n\n'"$self"$'\n'"$peers" \
      '{"text": $txt, "class": "connected", "alt": "connected", "tooltip": $tip}'
  else
    echo "{\"text\":\"\",\"class\":\"stopped\",\"alt\":\"stopped\", \"tooltip\": \"The VPN is not active.\"}"
  fi
  ;;
--toggle)
  toggle_status
  ;;
esac
