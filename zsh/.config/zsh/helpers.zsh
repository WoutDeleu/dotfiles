# Shared zsh helper functions. Loaded first in .zshrc so everything below can use them.

# Source an external config file only if it exists. Saves retyping the
# `[ -f file ] && source file` dance for every optional config.
src() { [ -f "$1" ] && source "$1"; }
