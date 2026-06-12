#!/bin/bash
# Tooltip detail: CPU, RAM, top processes
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
RAM=$(free -m | awk '/^Mem:/ {printf "%dMB / %dMB (%d%%)", $2-$7, $2, ($2-$7)/$2*100}')
SWAP=$(free -h | awk '/^Swap:/ {print $3 "/" $2}')
TOP=$(ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {printf "%-20s %s%%\n", $11, $3}')
echo "CPU: ${CPU}%"
echo "RAM: ${RAM}"
echo "Swap: ${SWAP}"
echo ""
echo "Top processes:"
echo "${TOP}"
