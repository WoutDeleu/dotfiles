# LAPTOP-ONLY layout — no external monitors connected.
#
#   eDP-1     -> everything (1..10)
#
# Fills the `map` and `isdef` arrays declared by the caller (apply()).
# Args: $1=laptop
layout_laptop() {
  local laptop="$1" w
  for w in 1 2 3 4 5 6 7 8 9 10; do map[$w]="$laptop"; done
  isdef=( [1]=1 )
}
