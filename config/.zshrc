# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme - agnoster is a nice built-in theme with powerline-like features
ZSH_THEME="agnoster"

# Enable command correction
ENABLE_CORRECTION="true"

# Display red dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(
    git
    docker
    sudo
    history
    copypath
    dirhistory
    jsontools
    colored-man-pages
    command-not-found
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias vi='vim'
alias fm='ranger'  # ranger file manager

# Check if bat is installed as batcat (Debian) and create alias
if command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# Load fzf if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-syntax-highlighting (must be at the end)
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Set up tab completion menu behavior (similar to PowerShell's MenuComplete)
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY         # Share history between sessions
setopt EXTENDED_HISTORY      # Add timestamps to history
setopt HIST_IGNORE_ALL_DUPS  # Don't record duplicates
setopt HIST_FIND_NO_DUPS     # Don't show duplicates in search

# Enable directory navigation with just the directory name
setopt autocd

# Key bindings
bindkey '^[[A' up-line-or-search       # Up arrow for history search
bindkey '^[[B' down-line-or-search     # Down arrow for history search
bindkey '^[[Z' reverse-menu-complete   # Shift+Tab to go backwards in completion menu