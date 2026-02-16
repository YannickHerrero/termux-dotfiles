#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Termux Dotfiles - Shell Setup
#
#  Installs and configures zsh with:
#    - Zinit plugin manager
#    - Oh My Posh prompt (zen theme, Catppuccin Mocha)
#    - fzf, zoxide, eza, bat
#
#  Called by install.sh (step_shell) or run standalone.
#
#  Usage: bash termux/setup-shell.sh
#######################################################

# ============== CONFIGURATION ==============
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============== UTILITY FUNCTIONS ==============

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}

    if dpkg -s "$pkg" > /dev/null 2>&1; then
        echo -e "  ${GRAY}-${NC} ${name} already installed"
    else
        pkg install -y "$pkg" > /dev/null 2>&1 || true
        echo -e "  ${GREEN}✓${NC} Installed ${name}"
    fi
}

# ============== INSTALL PACKAGES ==============

install_packages() {
    echo -e "  ${YELLOW}⏳${NC} Installing shell packages..."

    install_pkg "zsh" "Zsh"
    install_pkg "fzf" "fzf (fuzzy finder)"
    install_pkg "zoxide" "zoxide (smart cd)"
    install_pkg "eza" "eza (modern ls)"
    install_pkg "bat" "bat (syntax-highlighted cat)"
    install_pkg "git" "git"
}

# ============== INSTALL OH MY POSH ==============

install_oh_my_posh() {
    if command -v oh-my-posh > /dev/null 2>&1; then
        echo -e "  ${GRAY}-${NC} Oh My Posh already installed"
    else
        echo -e "  ${YELLOW}⏳${NC} Installing Oh My Posh..."
        curl -s https://ohmyposh.dev/install.sh | bash -s > /dev/null 2>&1
        echo -e "  ${GREEN}✓${NC} Installed Oh My Posh"
    fi
}

# ============== COPY CONFIGS ==============

# Copy a config file, backing up the destination if it differs
safe_copy() {
    local src=$1
    local dest=$2

    if [[ -f "$dest" ]] && ! diff -q "$src" "$dest" > /dev/null 2>&1; then
        cp "$dest" "${dest}.bak"
        echo -e "  ${YELLOW}!${NC} Backed up ${dest} -> ${dest}.bak"
    fi
    cp "$src" "$dest"
}

copy_configs() {
    echo -e "  ${YELLOW}⏳${NC} Copying shell configuration..."

    # Zsh config
    safe_copy "${SCRIPT_DIR}/.zshrc" ~/.zshrc
    echo -e "  ${GREEN}✓${NC} Copied ~/.zshrc"

    mkdir -p ~/.zsh
    for f in "${SCRIPT_DIR}/zsh/"*.zsh; do
        safe_copy "$f" ~/.zsh/"$(basename "$f")"
    done
    echo -e "  ${GREEN}✓${NC} Copied ~/.zsh/ modules"

    # Oh My Posh theme
    mkdir -p ~/.config/ohmyposh
    safe_copy "${SCRIPT_DIR}/ohmyposh/zen.toml" ~/.config/ohmyposh/zen.toml
    echo -e "  ${GREEN}✓${NC} Copied ~/.config/ohmyposh/zen.toml"
}

# ============== SET DEFAULT SHELL ==============

set_default_shell() {
    if [[ "$(basename "$SHELL")" == "zsh" ]]; then
        echo -e "  ${GRAY}-${NC} Zsh is already the default shell"
    else
        chsh -s zsh
        echo -e "  ${GREEN}✓${NC} Set zsh as default shell"
    fi
}

# ============== MAIN ==============

main() {
    install_packages
    install_oh_my_posh
    copy_configs
    set_default_shell

    echo -e "  ${GREEN}✓${NC} Shell setup complete"
}

main
