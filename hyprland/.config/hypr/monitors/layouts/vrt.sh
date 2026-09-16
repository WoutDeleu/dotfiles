# VRT (work) layout — laptop + both Lenovo work monitors (P24h-2L + P24q-20).
#
#   eDP-1 (laptop)   -> ws 8,9
#   P24h-2L (mid)    -> ws 3
#   P24q-20 (right)  -> ws 1,2,4,5,6,7,10
#
# Detection: both work monitors present (matched by description).

vrt_detect() {
  MON_LAPTOP=$(laptop_name)
  MON_MID=$(mon_name_by_desc "$WORK_MID_DESC")
  MON_RIGHT=$(mon_name_by_desc "$WORK_RIGHT_DESC")
  [ -n "$MON_MID" ] && [ -n "$MON_RIGHT" ]
}

vrt_workspaces() {
  map=( [8]="$MON_LAPTOP" [9]="$MON_LAPTOP" [3]="$MON_MID" \
        [1]="$MON_RIGHT" [2]="$MON_RIGHT" [4]="$MON_RIGHT" [5]="$MON_RIGHT" [6]="$MON_RIGHT" [7]="$MON_RIGHT" [10]="$MON_RIGHT" )
  isdef=( [8]=1 [3]=1 [1]=1 )
}
