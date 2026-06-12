#!/bin/bash
# Smart playerctl wrapper — controls the actively playing player,
# falls back to the first available player if nothing is playing.
# Usage: playerctl-smart.sh <command>  (play-pause, next, previous, etc.)

CMD="${1:-play-pause}"

mapfile -t players < <(playerctl -l 2>/dev/null)

player=""
for p in "${players[@]}"; do
    if [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
        player="$p"
        break
    fi
done

# Fall back to first player if nothing is Playing
[[ -z "$player" && ${#players[@]} -gt 0 ]] && player="${players[0]}"

[[ -n "$player" ]] && playerctl -p "$player" "$CMD"
