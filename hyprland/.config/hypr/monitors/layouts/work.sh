# WORK layout — laptop + both Lenovo work monitors.
#
#   eDP-1     -> 8, 9
#   P24h-2L   -> 3                    (middle)
#   P24q-20   -> 1,2,4,5,6,7,10       (right, "the rest")
#
# Fills the `map` and `isdef` arrays declared by the caller (apply()).
# Args: $1=laptop  $2=mid  $3=right
layout_work() {
  local laptop="$1" mid="$2" right="$3"
  map=( [8]="$laptop" [9]="$laptop" [3]="$mid" \
        [1]="$right" [2]="$right" [4]="$right" [5]="$right" [6]="$right" [7]="$right" [10]="$right" )
  isdef=( [8]=1 [3]=1 [1]=1 )
}
