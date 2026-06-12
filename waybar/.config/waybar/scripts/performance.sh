#!/bin/bash
# Quick CPU + RAM summary for waybar module
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
RAM=$(free -m | awk '/^Mem:/ {printf "%d", ($2-$7)/$2*100}')
echo "󰘚 ${CPU}%  󰍛 ${RAM}%"
