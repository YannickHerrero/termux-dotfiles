#!/bin/bash
set -euo pipefail
#######################################################
#  Arch Linux (proot) Setup Script
#
#  Runs inside the Arch proot-distro environment.
#  Installs packages, builds suckless tools, and
#  symlinks dotfiles into $HOME.
#
#  Called by: install.sh (via proot-distro login)
#######################################################

DOTFILES_DIR="/root/.dotfiles"

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ============== HELPER FUNCTIONS ==============

msg() {
    echo -e "  ${GREEN}✓${NC} $1"
}

msg_start() {
    echo -e "  ${YELLOW}⏳${NC} $1"
}

msg_error() {
    echo -e "  ${RED}✗${NC} $1"
}

# ============== STEP 1: SYSTEM UPDATE ==============

echo -e "${PURPLE}[1/4] Updating Arch packages...${NC}"
echo ""

pacman -Syu --noconfirm > /dev/null 2>&1
msg "System updated"

# ============== STEP 2: INSTALL PACKAGES ==============

echo ""
echo -e "${PURPLE}[2/4] Installing packages...${NC}"
echo ""

# Core X11 / desktop dependencies
msg_start "Installing X11 and desktop dependencies..."
pacman -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
    libx11 libxft libxinerama \
    fontconfig freetype2 \
    > /dev/null 2>&1
msg "X11 dependencies installed"

# Compositor + notifications
msg_start "Installing picom and dunst..."
pacman -S --needed --noconfirm \
    picom dunst libnotify \
    > /dev/null 2>&1
msg "picom + dunst installed"

# Applications
msg_start "Installing Firefox, ranger, and utilities..."
pacman -S --needed --noconfirm \
    firefox ranger \
    feh xclip xdotool \
    ttf-dejavu ttf-liberation noto-fonts \
    > /dev/null 2>&1
msg "Applications installed"

# Build tools (needed for suckless compilation)
msg_start "Installing build tools..."
pacman -S --needed --noconfirm \
    base-devel git \
    > /dev/null 2>&1
msg "Build tools installed"

# ============== STEP 3: BUILD SUCKLESS TOOLS ==============

echo ""
echo -e "${PURPLE}[3/4] Building suckless tools...${NC}"
echo ""

SUCKLESS_DIR="${DOTFILES_DIR}/suckless"
BUILD_DIR="/tmp/suckless-build"
mkdir -p "$BUILD_DIR"

build_suckless() {
    local name=$1
    local repo=$2
    local version=${3:-""}
    local build_path="${BUILD_DIR}/${name}"

    msg_start "Building ${name}..."

    # Clone source
    if [[ -d "$build_path" ]]; then
        rm -rf "$build_path"
    fi
    git clone "$repo" "$build_path" > /dev/null 2>&1

    # Checkout specific version if provided
    if [[ -n "$version" ]]; then
        git -C "$build_path" checkout "$version" > /dev/null 2>&1
    fi

    # Apply patches
    if [[ -d "${SUCKLESS_DIR}/${name}/patches" ]]; then
        for patch in "${SUCKLESS_DIR}/${name}/patches/"*.diff; do
            if [[ -f "$patch" ]]; then
                git -C "$build_path" apply "$patch" 2>/dev/null || \
                    patch -d "$build_path" -p1 < "$patch" 2>/dev/null || \
                    msg_error "Patch failed: $(basename "$patch")"
            fi
        done
    fi

    # Copy config.h if it exists (skip for st -- handled separately)
    if [[ "$name" != "st" ]] && [[ -f "${SUCKLESS_DIR}/${name}/config.h" ]]; then
        cp "${SUCKLESS_DIR}/${name}/config.h" "${build_path}/config.h"
    fi

    # Build and install
    make -C "$build_path" clean install > /dev/null 2>&1

    msg "Built and installed ${name}"
}

build_suckless "dwm"       "https://git.suckless.org/dwm"       "6.5"
build_suckless "dmenu"     "https://git.suckless.org/dmenu"     "5.3"
build_suckless "dwmblocks" "https://github.com/torrinfail/dwmblocks.git" ""

# Build st with sed-based customization of config.def.h
build_st() {
    local build_path="${BUILD_DIR}/st"

    msg_start "Building st..."

    if [[ -d "$build_path" ]]; then
        rm -rf "$build_path"
    fi
    git clone "https://git.suckless.org/st" "$build_path" > /dev/null 2>&1
    git -C "$build_path" checkout "0.9.2" > /dev/null 2>&1

    # Apply patches
    if [[ -d "${SUCKLESS_DIR}/st/patches" ]]; then
        for p in "${SUCKLESS_DIR}/st/patches/"*.diff; do
            if [[ -f "$p" ]]; then
                git -C "$build_path" apply "$p" 2>/dev/null || \
                    patch -d "$build_path" -p1 < "$p" 2>/dev/null || \
                    msg_error "Patch failed: $(basename "$p")"
            fi
        done
    fi

    # Customize config.def.h via sed (avoids maintaining a full config.h)
    local conf="${build_path}/config.def.h"

    # Font
    sed -i 's|^static char \*font = .*|static char *font = "DejaVu Sans Mono:pixelsize=16:antialias=true:autohint=true";|' "$conf"

    # Border
    sed -i 's|^static int borderpx.*|static int borderpx = 2;|' "$conf"

    # Tab width
    sed -i 's|^unsigned int tabspaces.*|unsigned int tabspaces = 4;|' "$conf"

    # Disable bell
    sed -i 's|^static int bellvolume.*|static int bellvolume = 0;|' "$conf"

    # Catppuccin Mocha colors
    sed -i '/^static const char \*colorname/,/^};/{
        s|"black"|"#45475a"|
        s|"red3"|"#f38ba8"|
        s|"green3"|"#a6e3a1"|
        s|"yellow3"|"#f9e2af"|
        s|"blue2"|"#89b4fa"|
        s|"magenta3"|"#f5c2e7"|
        s|"cyan3"|"#94e2d5"|
        s|"gray90"|"#bac2de"|
        s|"gray50"|"#585b70"|
        s|"red"|"#f38ba8"|
        s|"green"|"#a6e3a1"|
        s|"yellow"|"#f9e2af"|
        s|"\#4682b4"|"#89b4fa"|
        s|"magenta"|"#f5c2e7"|
        s|"cyan"|"#94e2d5"|
        s|"white"|"#a6adc8"|
    }' "$conf"

    # Set default fg/bg to Catppuccin Mocha Base/Text
    sed -i 's|^unsigned int defaultfg.*|unsigned int defaultfg = 257;|' "$conf"
    sed -i 's|^unsigned int defaultbg.*|unsigned int defaultbg = 256;|'  "$conf"
    sed -i 's|^static unsigned int defaultrcs.*|static unsigned int defaultrcs = 256;|' "$conf"
    # Patch the special color entries (256 -> bg, 257 -> fg) at end of colorname[]
    # In st's config.def.h, color 256 is the first color after [255] and color 257 is the second
    sed -i '/\[255\]/{ n; s|".*"|"#1e1e2e"|; n; s|".*"|"#cdd6f4"|; }' "$conf"

    make -C "$build_path" clean install > /dev/null 2>&1

    msg "Built and installed st"
}

build_st

# Cleanup build directory
rm -rf "$BUILD_DIR"

# ============== STEP 4: SYMLINK DOTFILES ==============

echo ""
echo -e "${PURPLE}[4/4] Linking dotfiles...${NC}"
echo ""

HOME_SRC="${DOTFILES_DIR}/home"

# Symlink everything from arch/home/ into $HOME
if [[ -d "$HOME_SRC" ]]; then
    # .xinitrc
    if [[ -f "${HOME_SRC}/.xinitrc" ]]; then
        ln -sf "${HOME_SRC}/.xinitrc" ~/.xinitrc
        msg "Linked .xinitrc"
    fi

    # .config directories
    if [[ -d "${HOME_SRC}/.config" ]]; then
        for dir in "${HOME_SRC}/.config/"*/; do
            local_dir=$(basename "$dir")
            mkdir -p ~/.config
            ln -sfn "$dir" ~/.config/"$local_dir"
            msg "Linked .config/${local_dir}"
        done
    fi
fi

# Make dwmblocks scripts executable
if [[ -d "${SUCKLESS_DIR}/dwmblocks/scripts" ]]; then
    chmod +x "${SUCKLESS_DIR}/dwmblocks/scripts/"* 2>/dev/null || true
    # Symlink scripts to a location on PATH
    mkdir -p /usr/local/bin
    for script in "${SUCKLESS_DIR}/dwmblocks/scripts/"*; do
        if [[ -f "$script" ]]; then
            ln -sf "$script" /usr/local/bin/"$(basename "$script")"
        fi
    done
    msg "Linked dwmblocks scripts"
fi

echo ""
msg "Arch Linux setup complete"
echo ""
