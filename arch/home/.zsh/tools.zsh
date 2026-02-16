# Oh My Posh prompt
if command -v oh-my-posh > /dev/null 2>&1; then
    oh-my-posh enable reload 2>/dev/null || true
    eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
fi

# Zoxide (smart cd)
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init --cmd z zsh)"
fi
