# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

### Powerlevel10k
source ~/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### PATH
export PATH="$HOME/.local/bin:$PATH"

### Aliases
alias ls="eza -a --icons=always --color=always"
alias v="nvim"
alias zshconfig="v ~/dotfiles/zsh/.zshrc"
alias zshsrc="source ~/.zshrc"

### Editor
export EDITOR=nvim
export VISUAL=nvim

### AI tooling
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

### Secrets (not tracked in git — see zsh/.zsh_secrets.example)
[ -f "$HOME/.zsh_secrets" ] && source "$HOME/.zsh_secrets"
