#!/usr/bin/env bash
source "$(dirname "$0")/waybar-helpers.sh"

mem_color=$(waybar_config_get "custom/ram" "color" "#8be9fd")
icon_mem=$(waybar_config_get "custom/ram" "icon" "")

# Get total used memory in GB and percentage
total_mem=$(free -k | awk '/^Mem:/ {printf "%.1f", $3/1048576}')
mem_pct=$(free -k | awk '/^Mem:/ {printf "%.1f", $3/$2*100}')

# Aggregate memory (RSS in KB) by resolved process name, show top 10
top_mem=$(ps -eo pid=,comm=,rss=,args= --no-headers | awk -v dmap="${docker_pid_container}" 'BEGIN {
  n=split(dmap, entries, " ")
  for (i=1; i<=n; i++) {
    eq=index(entries[i], "=")
    if (eq > 0) ctr[substr(entries[i], 1, eq-1)]=substr(entries[i], eq+1)
  }
} {
  pid=$1; comm=$2; rss=$3
  if (comm == "MainThread" || comm ~ /^\..*-wrap(ped)?$/) {
    name=""
    for (i=4; i<=NF; i++) {
      if ($i ~ /^-/) continue
      n=split($i, p, "/"); candidate=p[n]
      if (candidate != "" && candidate !~ /^(node|python[0-9.]*|bash|sh|zsh|env)$/) { name=candidate; break }
    }
    if (name == "") name=comm
  } else {
    name=comm
  }
  if (ctr[pid] != "") name=name " [D:" ctr[pid] "]"
  mem[name]+=rss
} END {for (name in mem) if (mem[name]>0) printf "%d %s\n", mem[name], name}' | sort -rn | head -10 | awk '{val=$1/1024; unit="M"; if(val>=1000){val/=1024; unit="G"} $1=""; sub(/^ /,""); printf "%5.1f%s  %s\n", val, unit, $0}')

# Build tooltip
mem_bar=$(make_bar "$mem_pct" 20)
tooltip="<b><span color='${mem_color}'>MEMORY</span></b>\\n${mem_bar}"
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  val=$(echo "$line" | awk '{print $1}')
  name=$(echo "$line" | awk '{$1=""; sub(/^ /,""); print}')
  padded_val=$(printf "%6s" "$val")
  tooltip+="\\n$(format_proc_line "${padded_val}" "$name")"
done <<< "$top_mem"

# Swap
swap_info=$(free -k | awk '/^Swap:/ {used=$3/1048576; total=$2/1048576; printf "%.1fG / %.1fG", used, total}')
tooltip+="\\n\\nSwap: ${swap_info}"

text="<span color='${mem_color}'>${total_mem}G<span size='40%'> </span>${icon_mem}</span>"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
