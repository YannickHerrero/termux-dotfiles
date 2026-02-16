#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Termux Dotfiles - Shell Setup
#
#  Installs and configures zsh with:
#    - Zinit plugin manager
#    - Starship prompt (Catppuccin Mocha)
#    - zoxide, eza, bat
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

# Verify a binary is available after install
verify_pkg() {
    local binary=$1
    local name=${2:-$binary}

    if ! command -v "$binary" > /dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} ${name} binary not found after install"
        echo -e "    Try manually: ${YELLOW}pkg install ${binary}${NC}"
        return 1
    fi
}

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

# ============== INSTALL PACKAGES ==============

install_packages() {
    echo -e "  ${YELLOW}⏳${NC} Installing shell packages..."

    install_pkg "zsh" "Zsh"
    install_pkg "starship" "Starship (prompt)"
    install_pkg "zoxide" "zoxide (smart cd)"
    install_pkg "eza" "eza (modern ls)"
    install_pkg "bat" "bat (syntax-highlighted cat)"
    install_pkg "git" "git"
}

# ============== VERIFY PACKAGES ==============

verify_packages() {
    echo -e "  ${YELLOW}⏳${NC} Verifying installed packages..."

    local failed=0
    verify_pkg "zsh" "Zsh"           || failed=1
    verify_pkg "starship" "Starship" || failed=1
    verify_pkg "zoxide" "zoxide"     || failed=1
    verify_pkg "eza" "eza"           || failed=1
    verify_pkg "bat" "bat"           || failed=1
    verify_pkg "git" "git"           || failed=1

    if [[ $failed -eq 1 ]]; then
        echo -e "  ${RED}✗${NC} Some packages failed to install"
        echo -e "    Run ${YELLOW}pkg update && pkg upgrade${NC} then try again"
        return 1
    fi

    echo -e "  ${GREEN}✓${NC} All packages verified"
}

# ============== COPY CONFIGS ==============

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

    # Starship config
    mkdir -p ~/.config
    safe_copy "${SCRIPT_DIR}/starship/starship.toml" ~/.config/starship.toml
    echo -e "  ${GREEN}✓${NC} Copied ~/.config/starship.toml"
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
    verify_packages
    copy_configs
    set_default_shell

    echo -e "  ${GREEN}✓${NC} Shell setup complete"
}

main
