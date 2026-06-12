#!/usr/bin/env bash
# Shared helpers for waybar custom modules

# Parse waybar config JSONC to extract module settings
# Usage: waybar_config_get <module> <key> [default]
waybar_config_get() {
  local module=$1 key=$2 default=${3:-}
  local config="$HOME/.config/waybar/config"

  local result
  result=$(awk -v mod="\"$module\"" -v k="\"$key\"" '
    { gsub(/\/\/.*/, "") }
    $0 ~ mod { in_mod=1; depth=0 }
    in_mod { depth += gsub(/{/, "{"); depth -= gsub(/}/, "}") }
    in_mod && depth == 0 && NR > 1 { in_mod=0 }
    in_mod && $0 ~ k {
      match($0, /: *"([^"]*)"/, m)
      if (m[1] != "") { print m[1]; exit }
    }
  ' "$config")

  echo "${result:-$default}"
}

# Generate a percentage bar with Pango markup
# Usage: make_bar <pct> <width> <fill_color>
make_bar() {
  local pct=$1 width=$2 fill_color=${3:-#50fa7b}
  local filled=$(awk "BEGIN {printf \"%d\", $pct/100*$width + 0.5}")
  local empty=$((width - filled))
  local bar="<span color='${fill_color}'>"
  for ((i=0; i<filled; i++)); do bar+="━"; done
  bar+="</span>"
  for ((i=0; i<empty; i++)); do bar+="━"; done
  bar+=" ${pct}%"
  echo "$bar"
}

# Collect PIDs running inside docker containers, mapped to container names
docker_pid_container=""
docker_color="#50a0e0"

if command -v docker &>/dev/null; then
  declare -A _cid_name=()
  while read -r cid cname; do
    [[ -n "$cid" ]] && _cid_name[$cid]=$cname
  done < <(docker ps --no-trunc --format '{{.ID}} {{.Names}}' 2>/dev/null)

  for _cgdir in /sys/fs/cgroup/system.slice/docker-*.scope; do
    [[ -f "$_cgdir/cgroup.procs" ]] || continue
    _cid=$(basename "$_cgdir")
    _cid=${_cid#docker-}
    _cid=${_cid%.scope}
    _cname=${_cid_name[$_cid]:-}
    [[ -z "$_cname" ]] && continue
    while read -r _pid; do
      [[ -n "$_pid" ]] && docker_pid_container+="${_pid}=${_cname} "
    done < "$_cgdir/cgroup.procs"
  done
  unset _cid_name _cgdir _cid _cname _pid
fi

# Format a process line for tooltip with docker container name
# Usage: format_proc_line <value> <name>
format_proc_line() {
  local val=$1 name=$2
  if [[ "$name" =~ \[D:([^]]+)\]$ ]]; then
    local container="${BASH_REMATCH[1]}"
    name="${name% \[D:*}"
    name="${name:0:14}"
    local pad=$(printf '%*s' $((${#val} + 2)) '')
    echo "${val}  ${name} <span color='${docker_color}'>[D]</span>\\n${pad}<span color='${docker_color}'>└ ${container}</span>"
  else
    name="${name:0:14}"
    echo "${val}  ${name}"
  fi
}
