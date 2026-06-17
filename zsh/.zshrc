# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Helpers — load first so the rest of this file can use them (e.g. `src`).
[ -f "$HOME/.config/zsh/helpers.zsh" ] && source "$HOME/.config/zsh/helpers.zsh"

### Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme is provided by Powerlevel10k (sourced manually below), so leave OMZ's
# theme empty to avoid loading robbyrussell on top of it.
ZSH_THEME=""

# Plugins MUST be set before sourcing oh-my-zsh.sh.
# syntax-highlighting must come last; autosuggestions just before it.
plugins=(
  git
  zsh-autosuggestions
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Include hidden files in completion/glob, but exclude . and .. from tab completion
setopt globdots
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'


### Powerlevel10k
source ~/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### PATH
export PATH="$HOME/.local/bin:$PATH"

### Aliases
alias ls="eza -a --icons=always --color=always"
alias cat="bat --paging=never"
alias v="nvim"
alias zshconfig="v ~/dotfiles/zsh/.zshrc"
alias zshsrc="source ~/.zshrc"
alias rm='trash-put'
alias rmf='/usr/bin/rm'
alias spotify='spotify_player'

### Editor
export EDITOR=nvim
export VISUAL=nvim

### fzf — fuzzy finder shell integration
# CTRL-R history search, CTRL-T file picker, ALT-C cd into dir.
command -v fzf >/dev/null && source <(fzf --zsh)

### Claude Code
src "$HOME/.config/zsh/claude-code.zsh"

### Secrets — machine-local, never tracked (folder: ~/.config/secrets/*.zsh)
for _secret in "$HOME"/.config/secrets/*.zsh(N); do source "$_secret"; done
unset _secret
### Terminal/tab title hooks (working dir when idle, command when running)
src "$HOME/.config/zsh/tab_title.zsh"

please() { sudo $(fc -ln -1) }


