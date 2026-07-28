# HOME layout — laptop + any single external monitor.
#
#   external  -> 1,2,3,4,7
#   eDP-1     -> 5,6,8,9,10
#
# Fills the `map` and `isdef` arrays declared by the caller (apply()).
# Args: $1=laptop  $2=external
layout_home() {
  local laptop="$1" ext="$2"
  map=( [1]="$ext" [2]="$ext" [3]="$ext" [4]="$ext" [7]="$ext" \
        [5]="$laptop" [6]="$laptop" [8]="$laptop" [9]="$laptop" [10]="$laptop" )
  isdef=( [1]=1 [8]=1 )
}
