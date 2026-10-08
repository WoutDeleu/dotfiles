#!/usr/bin/env bash
# Orchestrator — detect the connected monitors, pick a layout profile, and apply
# its workspace -> monitor mapping. Monitor arrangement is owned by nwg-displays
# and loaded from ~/.config/hypr/monitors.lua.
#
# Layout profiles live in ./layouts/*.sh. Each profile <name> defines:
#   <name>_detect      -> sets MON_* globals, returns 0 if this profile matches
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

laptop_name() {
  local n
  n=$(jq -r --arg n "$LAPTOP" '.[] | select(.name==$n) | .name' <<<"$MONS" | head -1)
  [ -z "$n" ] && n=$(jq -r '.[] | select(.name|startswith("eDP")) | .name' <<<"$MONS" | head -1)
  printf '%s' "$n"
}

# Physical lid state ("open"/"closed") from the ACPI button, so we never light
# up the internal panel while the laptop is shut.
lid_state() {
  local f
  for f in /proc/acpi/button/lid/*/state; do
    [ -r "$f" ] || continue
    grep -qi closed "$f" && { printf 'closed'; return; }
  done
  printf 'open'
}

# Number of enabled monitors other than the laptop panel.
other_enabled_count() {
  jq --arg n "$1" '[.[] | select(.name != $n and .disabled != true)] | length' <<<"$MONS"
}

# Lid closed: disable the laptop panel only when docked. Undocked, logind
# suspends anyway; disabling the last output makes Hyprland swap in FALLBACK,
# so hyprlock loses its eDP-1 surface and "lockscreen died" flashes on resume.
lid_close() {
  MONS=$(hyprctl monitors all -j) || return 1
  local laptop
  laptop=$(laptop_name)
  [ -n "$laptop" ] || return 0
  if [ "$(other_enabled_count "$laptop")" -gt 0 ]; then
    hyprctl eval "hl.monitor({output=\"$laptop\", disabled=true})" >/dev/null 2>&1
  fi
}

apply() {
  # `monitors all` (not just enabled ones) so a panel that got disabled by a
  # lid-close/suspend stays visible here and can be recovered.
  MONS=$(hyprctl monitors all -j) || return 1

  # Reconcile the laptop panel with the physical lid. Reloading on a missed
  # lid-open event restores the nwg-displays layout instead of inventing one.
  if [ "$(lid_state)" = "closed" ]; then
    local laptop
    laptop=$(laptop_name)
    if [ -n "$laptop" ]; then
      if [ "$(other_enabled_count "$laptop")" -gt 0 ]; then
        hyprctl eval "hl.monitor({output=\"$laptop\", disabled=true})" >/dev/null 2>&1
        MONS=$(jq --arg n "$laptop" 'map(select(.name != $n))' <<<"$MONS")
      elif [ "$(jq -r --arg n "$laptop" '.[] | select(.name==$n) | .disabled' <<<"$MONS")" = "true" ]; then
        # Undocked with the panel off (e.g. external unplugged while shut):
        # bring it back so there is a real output to lock before suspend.
        hyprctl reload >/dev/null 2>&1
        MONS=$(hyprctl monitors all -j) || return 1
      fi
    fi
  else
    local laptop
    laptop=$(laptop_name)
    if [ -n "$laptop" ] && [ "$(jq -r --arg n "$laptop" '.[] | select(.name==$n) | .disabled' <<<"$MONS")" = "true" ]; then
      hyprctl reload >/dev/null 2>&1
      MONS=$(hyprctl monitors all -j) || return 1
    fi
  fi

  local selected="" L
  for L in "${LAYOUTS[@]}"; do
    if "${L}_detect"; then selected="$L"; break; fi
  done
  [ -z "$selected" ] && return 0

  # Workspace -> monitor mapping.
  declare -A map     # ws -> monitor name
  declare -A isdef   # ws -> 1 when it is the default workspace for its monitor
  "${selected}_workspaces"

  local w m batch=""
  for w in 1 2 3 4 5 6 7 8 9 10; do
    m=${map[$w]}
    [ -z "$m" ] && continue
    if [ "${isdef[$w]}" = "1" ]; then
      batch+="eval hl.workspace_rule({workspace=\"$w\", monitor=\"$m\", default=true}) ; "
    else
      batch+="eval hl.workspace_rule({workspace=\"$w\", monitor=\"$m\"}) ; "
    fi
  done
  [ -n "$batch" ] && hyprctl --batch "$batch" >/dev/null

  # Move already-open workspaces onto their target monitor.
  local open
  open=$(hyprctl workspaces -j | jq -r '.[].id')
  for w in $open; do
    case "$w" in ''|*[!0-9]*) continue ;; esac   # skip special/negative
    m=${map[$w]}
    [ -n "$m" ] && hyprctl dispatch "hl.dsp.workspace.move({workspace=$w, monitor=\"$m\"})" >/dev/null 2>&1
  done
}

watch() {
  local last="" cur snap
  while true; do
    # Track disabled state and lid position too, so a stuck-off panel or a
    # lid open/close both trigger a re-apply (monitors all => disabled visible).
    snap=$(hyprctl monitors all -j 2>/dev/null | jq -Sc '[.[] | {name, description, disabled}]' 2>/dev/null)
    if [ -n "$snap" ]; then
      cur="${snap}|$(lid_state)"
      if [ "$cur" != "$last" ]; then
        apply
        last="$cur"
      fi
    fi
    sleep 2
  done
}

case "${1:-apply}" in
  apply) apply ;;
  watch) watch ;;
  lid-close) lid_close ;;
  *) echo "usage: ${0##*/} {apply|watch|lid-close}" >&2; exit 1 ;;
esac
