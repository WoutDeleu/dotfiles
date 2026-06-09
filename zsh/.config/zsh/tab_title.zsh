# Terminal/tab title: working dir when idle, command name while running.
# For ssh/mosh, show the full command so the host stays visible.
autoload -Uz add-zsh-hook
_title_idle() { print -Pn "\e]2;%1~\a" }          # last path component, ~ for home
_title_cmd() {                                     # command name, but full cmd for remote sessions
  case "$1" in
    ssh*|mosh*) print -n  "\e]2;${1}\a" ;;         # "ssh user@host"
    *)          print -Pn "\e]2;${1%% *}\a" ;;     # first word of the command
  esac
}
add-zsh-hook precmd  _title_idle
add-zsh-hook preexec _title_cmd
