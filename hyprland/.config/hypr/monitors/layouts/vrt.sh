# VRT (work) layout — laptop + both Lenovo work monitors (P24h-2L + P24q-20).
#
# Arrangement (top-left origin):
#   eDP-1 (laptop)   far left, dropped lower so its bottom aligns with the row
#   P24h-2L (mid)    top row, right of the laptop   -> ws 3
#   P24q-20 (right)  top row, far right             -> ws 1,2,4,5,6,7,10
#
# Detection: both work monitors present (matched by description).

vrt_detect() {
  MON_LAPTOP=$(laptop_name)
  MON_MID=$(mon_name_by_desc "$WORK_MID_DESC")
  MON_RIGHT=$(mon_name_by_desc "$WORK_RIGHT_DESC")
  [ -n "$MON_MID" ] && [ -n "$MON_RIGHT" ]
}

vrt_arrange() {
  local lw lh mw mh y
  lw=$(mon_field "$MON_LAPTOP" width);  lh=$(mon_field "$MON_LAPTOP" height)
  mw=$(mon_field "$MON_MID" width);     mh=$(mon_field "$MON_MID" height)
  y=$(( mh - lh )); [ "$y" -lt 0 ] && y=0     # drop the laptop lower (bottom-aligned)

  echo "monitor $MON_LAPTOP,preferred,0x${y},1"
  echo "monitor $MON_MID,preferred,${lw}x0,1"
  echo "monitor $MON_RIGHT,preferred,$(( lw + mw ))x0,1"
}

vrt_workspaces() {
  map=( [8]="$MON_LAPTOP" [9]="$MON_LAPTOP" [3]="$MON_MID" \
        [1]="$MON_RIGHT" [2]="$MON_RIGHT" [4]="$MON_RIGHT" [5]="$MON_RIGHT" [6]="$MON_RIGHT" [7]="$MON_RIGHT" [10]="$MON_RIGHT" )
  isdef=( [8]=1 [3]=1 [1]=1 )
}
