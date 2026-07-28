# LAPTOP-ONLY layout — fallback when no external monitor matches another profile.
#
#   eDP-1 -> everything (1..10)

laptop_detect() {
  MON_LAPTOP=$(laptop_name)
  [ -n "$MON_LAPTOP" ]
}

laptop_arrange() {
  echo "monitor $MON_LAPTOP,preferred,0x0,1"
}

laptop_workspaces() {
  local w
  for w in 1 2 3 4 5 6 7 8 9 10; do map[$w]="$MON_LAPTOP"; done
  isdef=( [1]=1 )
}
