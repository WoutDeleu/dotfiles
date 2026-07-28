#!/usr/bin/env bash
# Orchestrator — detect the connected monitors, pick a layout profile, and apply
# both its monitor arrangement (positions) and its workspace -> monitor mapping.
#
# Layout profiles live in ./layouts/*.sh. Each profile <name> defines:
#   <name>_detect      -> sets MON_* globals, returns 0 if this profile matches
#   <name>_arrange     -> prints `monitor <spec>` lines on stdout (positions)
#   <name>_workspaces  -> fills the `map` (ws -> monitor) and `isdef` arrays
#
# Profiles are tried in LAYOUTS order; the first whose *_detect succeeds wins.
# Detection is by monitor *description* so it survives DP-x name changes.
#
# Run `monitor-workspaces.sh apply` once, or `watch` to keep it in sync as
# monitors are hot-plugged (dependency-free poll loop, no socat/python needed).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYOUT_DIR="$SCRIPT_DIR/layouts"

# Profile priority — most specific first.
LAYOUTS=(vrt home laptop)

LAPTOP="eDP-1"
WORK_MID_DESC="P24h-2L"     # middle work monitor -> gets ws 3
WORK_RIGHT_DESC="P24q-20"   # right work monitor  -> gets the rest

# Load layout definitions.
for f in "$LAYOUT_DIR"/*.sh; do
  [ -r "$f" ] && source "$f"
done

# --- helpers available to layout profiles (read the shared $MONS json) -------

mon_name_by_desc() { jq -r --arg d "$1" '.[] | select(.description|contains($d)) | .name' <<<"$MONS" | head -1; }
mon_field()        { jq -r --arg n "$1" --arg f "$2" '.[] | select(.name==$n) | .[$f]' <<<"$MONS" | head -1; }

laptop_name() {
  local n
  n=$(jq -r --arg n "$LAPTOP" '.[] | select(.name==$n) | .name' <<<"$MONS" | head -1)
  [ -z "$n" ] && n=$(jq -r '.[] | select(.name|startswith("eDP")) | .name' <<<"$MONS" | head -1)
  printf '%s' "$n"
}

apply() {
  MONS=$(hyprctl monitors -j) || return 1

  local selected="" L
  for L in "${LAYOUTS[@]}"; do
    if "${L}_detect"; then selected="$L"; break; fi
  done
  [ -z "$selected" ] && return 0

  # 1) Monitor arrangement (positions).
  local arrange_batch="" line
  while IFS= read -r line; do
    [ -n "$line" ] && arrange_batch+="keyword $line ; "
  done < <("${selected}_arrange")
  [ -n "$arrange_batch" ] && hyprctl --batch "$arrange_batch" >/dev/null

  # 2) Workspace -> monitor mapping.
  declare -A map     # ws -> monitor name
  declare -A isdef   # ws -> 1 when it is the default workspace for its monitor
  "${selected}_workspaces"

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
