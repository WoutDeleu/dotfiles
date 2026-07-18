# Build AUR packages against the SYSTEM Python, not mise's.
#
# `mise activate` puts its managed Python (e.g. 3.14) first on PATH, so a bare
# `python` resolves to ~/.local/share/mise/... instead of /usr/bin/python.
# AUR PKGBUILDs run `python -m build` / `python -m installer`, whose modules
# live only in the pacman-installed system Python and whose install prefix must
# be /usr. Hitting mise's Python instead causes "No module named build" and
# wrong install paths -> makepkg aborts with "exit status 4" for every Python
# AUR package (hyprmod, python-hyprland-*, etc.).
#
# These wrappers strip mise's dirs from PATH for the build subprocess only; the
# interactive shell's PATH (and your project Python) is left untouched.

# Echo $PATH with any entry pointing into the mise install tree removed.
_path_without_mise() {
  local dir clean=""
  for dir in ${(s/:/)PATH}; do
    case "$dir" in
      *.local/share/mise/*|*/.mise/*) ;;
      *) clean="${clean:+$clean:}$dir" ;;
    esac
  done
  print -r -- "$clean"
}

yay() {
  PATH="$(_path_without_mise)" command yay "$@"
}

makepkg() {
  PATH="$(_path_without_mise)" command makepkg "$@"
}
