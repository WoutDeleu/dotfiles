#!/usr/bin/env bash
source "$(dirname "$0")/waybar-helpers.sh"

cpu_color=$(waybar_config_get "custom/cpu" "color" "#ffb86c")
icon_cpu=$(waybar_config_get "custom/cpu" "icon" "")

# Normalize CPU% across all cores to match btop (0-100% total)
ncpu=$(nproc)

# Get total CPU usage
total_cpu=$(top -b -n1 -w 256 | awk -v n="$ncpu" 'NR>7 {sum+=$9} END {printf "%.1f", sum/n}')

# Aggregate CPU by process name, resolving generic names (MainThread, .wrap) to real commands
top_procs=$({
  ps -eo pid=,comm=,args= --no-headers | awk -v dmap="${docker_pid_container}" 'BEGIN {
    n=split(dmap, entries, " ")
    for (i=1; i<=n; i++) {
      eq=index(entries[i], "=")
      if (eq > 0) ctr[substr(entries[i], 1, eq-1)]=substr(entries[i], eq+1)
    }
  } {
    pid=$1; comm=$2
    if (comm == "MainThread" || comm ~ /^\..*-wrap(ped)?$/) {
      name=""
      for (i=3; i<=NF; i++) {
        if ($i ~ /^-/) continue
        n=split($i, p, "/"); candidate=p[n]
        if (candidate != "" && candidate !~ /^(node|python[0-9.]*|bash|sh|zsh|env)$/) { name=candidate; break }
      }
      if (name == "") name=comm
    } else {
      name=comm
    }
    if (ctr[pid] != "") name=name " [D:" ctr[pid] "]"
    print "PS", pid, name
  }'
  top -b -n1 -o %CPU -w 256 | awk 'NR>7 && $9+0>0 {print "TOP", $1, $9}'
} | awk -v n="$ncpu" '
  $1=="PS" { name[$2]=""; for(i=3;i<=NF;i++) name[$2]=(name[$2] ? name[$2] " " : "") $i }
  $1=="TOP" { pid=$2; cpu=$3; nm=(name[pid] ? name[pid] : "?"); agg[nm]+=cpu/n }
  END { for (nm in agg) if (nm != "?") printf "%.1f %s\n", agg[nm], nm }
' | sort -rn | head -10)

# Build tooltip
cpu_bar=$(make_bar "$total_cpu" 20)
tooltip="<b><span color='${cpu_color}'>CPU</span></b>\\n${cpu_bar}"
while IFS= read -r line; do
  cpu=$(echo "$line" | awk '{printf "%5.1f", $1}')
  name=$(echo "$line" | awk '{$1=""; sub(/^ /,""); print}')
  tooltip+="\\n$(format_proc_line "${cpu}%" "$name")"
done <<< "$top_procs"

# Load average
load_info=$(awk '{printf "%s  %s  %s", $1, $2, $3}' /proc/loadavg)
tooltip+="\\n\\nLoad: ${load_info}"

text="<span color='${cpu_color}'>${total_cpu}%<span size='40%'> </span>${icon_cpu}</span>"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
