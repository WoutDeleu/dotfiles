# HOME layout — laptop + any single external monitor.
#
# Arrangement: external on the left, laptop to its right (same top row).
#   external  -> ws 1,2,3,4,7
#   eDP-1     -> ws 5,6,8,9,10
#
# Detection: exactly the laptop plus at least one non-laptop monitor.

home_detect() {
  MON_LAPTOP=$(laptop_name)
  MON_EXT=$(jq -r --arg l "$MON_LAPTOP" '.[] | select(.name != $l) | .name' <<<"$MONS" | head -1)
  [ -n "$MON_EXT" ]
}

home_arrange() {
  local ew
  ew=$(mon_field "$MON_EXT" width)
  echo "monitor $MON_EXT,preferred,0x0,1"
  echo "monitor $MON_LAPTOP,preferred,${ew}x0,1"
}

home_workspaces() {
  map=( [1]="$MON_EXT" [2]="$MON_EXT" [3]="$MON_EXT" [4]="$MON_EXT" [7]="$MON_EXT" \
        [5]="$MON_LAPTOP" [6]="$MON_LAPTOP" [8]="$MON_LAPTOP" [9]="$MON_LAPTOP" [10]="$MON_LAPTOP" )
  isdef=( [1]=1 [8]=1 )
}
