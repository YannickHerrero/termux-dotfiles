# Text Editors & Files
alias v="nvim"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias oc="opencode"
alias mkcd='function _mkcd() { mkdir -p "$1" && cd "$1" }; _mkcd'
alias vswap="rm -rf ~/.local/state/nvim/swap/"

# Modern replacements (fall back to originals if not installed)
if command -v eza > /dev/null 2>&1; then
    alias ls='eza --color=always --icons=auto'
    alias ll='eza -la --color=always --icons=auto'
    alias lt='eza --tree --level=2 --color=always --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
fi

if command -v bat > /dev/null 2>&1; then
    alias cat='bat --plain'
fi

# Git shortcuts
alias gst='git status'
alias gck='git checkout'
alias glo='git log'
