fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/opt/trash/bin:$PATH"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
GIT_AUTO_FETCH_INTERVAL=1200 # in seconds


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git-auto-fetch
    git
    zsh-autosuggestions
    yarn
    web-search
    zsh-syntax-highlighting
    pip
    jsontools
    macports
    node
    sudo
    thor
    docker
    iterm2
)


source $ZSH/oh-my-zsh.sh

export VISUAL="nvim"
export EDITOR="nvim"
# User configuration

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias ll='colorls -la --sd --gs --group-directories-first'
alias ls='colorls -a --group-directories-first'
alias rm="trash"
# alias cat="bat --paging=never"
alias v="nvim"
alias please='sudo $(fc -ln -1)'
alias please='sudo $(fc -ln -1)'
alias extract-files='find . -type f -exec mv {} ./ \;'
alias open='xdg-open'
alias python='python3'

# Git
function lazygit() {
    git add .
    git commit -a -m "$1"
    git push
}
alias gg='git graph --style round'
# delete all branches except current
function gdb() {
    # Update remote references
    git fetch --prune
    # Identify and delete local branches that no longer exist on remote
    git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D
}
# Directory navigation
function brain() {
    local prev_dir="$PWD"
    cd ~/Documents/Programming/ClaudePersonalSetup
    claude
    cd "$prev_dir"
}
alias axxes='cd ~/Documents/AXXES/'
# volvo
alias volvo='cd ~/Documents/AXXES/Projects/Volvo'
alias keycloak="cd ~/Documents/AXXES/Projects/Volvo/Repositories/mfg-keycloak-administrator-tool"
alias vending="cd ~/Documents/AXXES/Projects/Volvo/Repositories/mfg-plant-maintenance-maximo-to-s4m-adapter"
alias linux="cd ~/Documents/Programming/linux-setup"
alias personal-site="cd ~/Documents/Programming/Portfolio"

# Google calendar
alias cadd='gcalcli add'
alias cm='gcalcli calm --monday --military'
alias cw='gcalcli calw --monday --military'
alias ca='gcalcli agenda --military'  
alias ce='gcalcli edit --military --nostarted'

# Google Tasks
alias taskl='gtasks tasks view'
alias taska='gtasks tasks add' 
alias taskd='gtasks tasks done'

# Tmux
# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'
# Creates a new session
alias tn='tmux new-session -s '
# Kill session
alias tk='tmux kill-session -t '
# Lists all ongoing sessions
alias tl='tmux list-sessions'
# Detach from session
alias td='tmux detach'
# Tmux Clear pane
alias tc='clear; tmux clear-history; clear'


source ~/.oh-my-zsh/custom/themes/powerlevel10k

function yt-dl() {
    yt-dlp --ignore-errors --continue --no-overwrites --download-archive Downloads/progress.txt -x -f m4a --add-metadata --embed-thumbnail -o "~/Downloads/YT-DL/%(title)s.% (ext)s" "$1"
}

mkcdir ()
{
    mkdir -p -- "$1" &&
       cd -P -- "$1"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Print logo every time opens and when clear is used 
# alias clear="clear && neofetch"

# time management visualiser
watson-visualiser() {
    python ~/Documents/Projects/Scripts/WatsonVisualiser.py "$(watson log -w --csv)" $1

}

# Timer functionallitty
countdown() {
    start="$(( $(date '+%s') + $1))"
    while [ $start -ge $(date +%s) ]; do
        time="$(( $start - $(date +%s) ))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}


# Generate Maven Project
mvn-default() {
    groupid='com.$1.$2'
    artifactid='$2'
    mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
}




stopwatch() {
    start=$(date +%s)
    while true; do
        time="$(( $(date +%s) - $start))"
        printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
        sleep 0.1
    done
}
# sourceable pomodoro command
pomodoro() {

    # print help
    echo_help() {
       # Display help
       echo "Pomodoro timer for the terminal."
       echo
       echo "Syntax: pomodoro [ OPTIONS ]"
       echo "options:"
       echo "   -s or --short-break [INTEGER]"
       echo "       length of short breaks in seconds"
       echo "   -l or --long-break [INTEGER]"
       echo "       length of long breaks in seconds"
       echo "   -w or --work [INTEGER]"
       echo "       length of work interval in seconds"
       echo "   -q or --quiet"
       echo "       do not show notifications"
       echo "   -h or --help"
       echo "       print help and exit"
       echo
    }

    # Default arguments
    WORK=1500       # 25 mins
    SHORT_BREAK=300 # 5 mins
    LONG_BREAK=1800 # 30 mins
    QUIET=false

    # Parse arguments
    for i in "$@"; do
      case $i in
        -h|--help)
          echo_help
          return;
          ;;
        -s|--short-break)
          if [[ $2 =~ ^-?[0-9]+$ ]]
          then
            SHORT_BREAK=$2
            shift # past argument
            shift # past value
          else
            echo_help
            return;
          fi
          ;;
        -l|--long-break)
          if [[ $2 =~ ^-?[0-9]+$ ]]
          then
            LONG_BREAK=$2
            shift # past argument
            shift # past value
          else
            echo_help
            return;
          fi
          ;;
        -w|--work)
          if [[ $2 =~ ^-?[0-9]+$ ]]
          then
            WORK="$2"
            shift # past argument
            shift # past value
          else
            echo_help
            return;
          fi
          ;;
        -q|--quiet)
          QUIET=true
          shift # past argument
          ;;
        -*|--*)
          echo "Unknown option $1"
          echo_help
          return;
          ;;
      esac
    done

    # show notification
    notify() {
        msg=$1
        secs=$2
        time=$(convert_secs $secs)
        notify-send --urgency=CRITICAL -i text-editor "Pomodoro" "$msg\n$time"
    }

    # convert notifications to h:m:s format
    convert_secs() {
        secs=${1}
        printf "%dh:%dm:%ds" $((secs/3600)) $((secs%3600/60)) $((secs%60))
    }
export SF_API_CLIENT_ID="..."

    # start a countdown for x seconds
    countdown() {
      secs=$1
      shift
      msg=$@
      while [ $secs -gt 0 ]
      do
        t=$(convert_secs $secs)
        printf "\r\033[K$msg $t"
        ((secs--))
        sleep 1
      done
      echo
    }

    # single step pomodoro step (work / break interval)
    pomodoro_step() {
      if ! $QUIET; then
        notify "$1!" $2
      fi
      countdown $2 "$1:"
    }

    # main pomodoro loop (infinite)
    pomodoro_loop() {
        counter=1
        while true; do
            for i in {1..3}; do
                echo "Pomodoro #$((counter++)) ..."
                pomodoro_step "Work" $WORK
                pomodoro_step "Break" $SHORT_BREAK
            done
            echo "Pomodoro #$((counter++)) ..."
            pomodoro_step "Work" $WORK
            pomodoro_step "Break" $LONG_BREAK
            done
    }

    echo "Pomodoro Timer ==="
    echo "Work: $WORK sec"
    echo "Short break: $SHORT_BREAK sec"
    echo "Long break: $LONG_BREAK sec"

    pomodoro_loop


}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Load Angular CLI autocompletion.
source <(ng completion script)



# Intellula
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
export ANTHROPIC_BASE_URL="https://bridge.ai.axxes.com"
export ANTHROPIC_API_KEY="CfDJ8PLgojjKDcJIqoEy5ujOZ0Y6wwmEAM7ZSrD0CGXOD7GGQsc5J74HdjzEuOVF4AgLUBFRGYm86N7pLvl356V9YLRrieYvOJuDnMXgZFJOb2msLzaFTv0-5dgzyn6zNDz8pvKkaNAxJvycVqatiIRaHsQ"
export OPENAI_BASE_URL="https://bridge.ai.axxes.com/v1"
export OPENAI_API_KEY="CfDJ8PLgojjKDcJIqoEy5ujOZ0Y6wwmEAM7ZSrD0CGXOD7GGQsc5J74HdjzEuOVF4AgLUBFRGYm86N7pLvl356V9YLRrieYvOJuDnMXgZFJOb2msLzaFTv0-5dgzyn6zNDz8pvKkaNAxJvycVqatiIRaHsQ"
export ANTHROPIC_MODEL="claude-sonnet-4-6"

# Advent of Code session cookie (added by setup-session.sh)
export AOC_SESSION='53616c7465645f5f5355da2dba9af3a4dc0569b6c6d0702b6625c190ce00facb9d2190455d9c9bcf702625aa799badbaff2c3b21562d47be0dd90adfabb0f615'
export PATH="$HOME/.local/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Timesheets app launcher
alias timesheets="~/Documents/Programming/Timesheets/start.sh"

# AI Email Assistant
alias emailai="~/Documents/Programming/EmailAiAssistent/start.sh"
