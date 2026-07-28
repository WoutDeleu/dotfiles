#!/usr/bin/env bash
# Dynamically assign workspaces to monitors based on which displays are connected.
#
# Layout definitions live in ./layouts/*.sh — each defines a layout_<name>
# function that fills the `map` (ws -> monitor name) and `isdef` (ws -> 1 when
# it is the default workspace for its monitor) associative arrays:
#
#   layouts/work.sh    WORK   (laptop + both Lenovo work monitors)
#   layouts/home.sh    HOME   (laptop + any single external)
#   layouts/laptop.sh  LAPTOP (no external)
#
# Detection is by monitor *description* so it survives DP-x name changes.
# Run `monitor-workspaces.sh apply` once, or `watch` to keep it in sync as
# monitors are hot-plugged (dependency-free poll loop, no socat/python needed).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYOUT_DIR="$SCRIPT_DIR/layouts"

LAPTOP="eDP-1"
WORK_MID_DESC="P24h-2L"     # middle work monitor -> gets ws 3
WORK_RIGHT_DESC="P24q-20"   # right work monitor  -> gets the rest

# Load layout definitions (defines layout_work / layout_home / layout_laptop).
for f in "$LAYOUT_DIR"/*.sh; do
  [ -r "$f" ] && source "$f"
done

apply() {
  local mons laptop mid right ext
  mons=$(hyprctl monitors -j) || return 1

  laptop=$(jq -r --arg n "$LAPTOP" '.[] | select(.name==$n) | .name' <<<"$mons" | head -1)
  [ -z "$laptop" ] && laptop=$(jq -r '.[] | select(.name|startswith("eDP")) | .name' <<<"$mons" | head -1)

  mid=$(jq -r --arg d "$WORK_MID_DESC"   '.[] | select(.description|contains($d)) | .name' <<<"$mons" | head -1)
  right=$(jq -r --arg d "$WORK_RIGHT_DESC" '.[] | select(.description|contains($d)) | .name' <<<"$mons" | head -1)
  # first external that is not the laptop (used for HOME layout)
  ext=$(jq -r --arg l "$laptop" '.[] | select(.name != $l) | .name' <<<"$mons" | head -1)

  declare -A map     # ws -> monitor name
  declare -A isdef   # ws -> 1 when it is the default workspace for its monitor

  if [ -n "$mid" ] && [ -n "$right" ]; then
    layout_work "$laptop" "$mid" "$right"
  elif [ -n "$ext" ]; then
    layout_home "$laptop" "$ext"
  else
    layout_laptop "$laptop"
  fi

  local w m batch=""
  for w in 1 2 3 4 5 6 7 8 9 10; do
    m=${map[$w]}
    [ -z "$m" ] && continue
    if [ "${isdef[$w]}" = "1" ]; then
      batch+="keyword workspace $w,monitor:$m,default:true ; "
    else
      batch+="keyword workspace $w,monitor:$m ; "
    fi
  done
  [ -n "$batch" ] && hyprctl --batch "$batch" >/dev/null

  # Move already-open workspaces onto their target monitor.
  local open
  open=$(hyprctl workspaces -j | jq -r '.[].id')
  for w in $open; do
    case "$w" in ''|*[!0-9]*) continue ;; esac   # skip special/negative
    m=${map[$w]}
    [ -n "$m" ] && hyprctl dispatch moveworkspacetomonitor "$w $m" >/dev/null 2>&1
  done
}

watch() {
  local last="" cur
  while true; do
    cur=$(hyprctl monitors -j 2>/dev/null | jq -Sc '[.[] | {name, description}]' 2>/dev/null)
    if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
      apply
      last="$cur"
    fi
    sleep 2
  done
}

case "${1:-apply}" in
  apply) apply ;;
  watch) watch ;;
  *) echo "usage: ${0##*/} {apply|watch}" >&2; exit 1 ;;
esac
