#!/bin/bash
set -euo pipefail
#######################################################
#  Arch Linux (proot) Setup Script
#
#  Runs inside the Arch proot-distro environment.
#  Installs packages, builds suckless tools, and
#  symlinks dotfiles into $HOME.
#
#  Usage:
#    bash setup.sh              # Full setup (packages + build + dotfiles)
#    bash setup.sh --skip-build # Skip suckless rebuilds (safe from st)
#    bash setup.sh --build-only # Rebuild suckless tools + relink dotfiles only
#
#  Called by: install.sh (via proot-distro login)
#######################################################

SKIP_BUILD=false
BUILD_ONLY=false
case "${1:-}" in
    --skip-build) SKIP_BUILD=true ;;
    --build-only) BUILD_ONLY=true ;;
esac

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

if [[ "$BUILD_ONLY" == true ]]; then
    echo -e "${PURPLE}[1/7] Skipping system update (--build-only)${NC}"
else

echo -e "${PURPLE}[1/7] Updating Arch packages...${NC}"
echo ""

pacman -Syu --noconfirm
msg "System updated"

fi  # end BUILD_ONLY skip

# ============== STEP 2: INSTALL PACKAGES ==============

if [[ "$BUILD_ONLY" == true ]]; then
    echo -e "${PURPLE}[2/7] Skipping package install (--build-only)${NC}"
else

echo ""
echo -e "${PURPLE}[2/7] Installing packages...${NC}"
echo ""

# Core X11 / desktop dependencies
msg_start "Installing X11 and desktop dependencies..."
pacman -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
    libx11 libxft libxinerama libxrender \
    fontconfig freetype2 harfbuzz
msg "X11 dependencies installed"

# Compositor + notifications
msg_start "Installing picom and dunst..."
pacman -S --needed --noconfirm \
    picom dunst libnotify
msg "picom + dunst installed"

# Applications
msg_start "Installing Firefox, ranger, and utilities..."
pacman -S --needed --noconfirm \
    firefox ranger \
    feh xclip xdotool \
    fastfetch btop \
    ttf-jetbrains-mono-nerd ttf-dejavu ttf-liberation noto-fonts
msg "Applications installed"

# Wallpaper selector + pywal dependencies
msg_start "Installing nsxiv and pywal16 dependencies..."
pacman -S --needed --noconfirm \
    nsxiv xorg-xrdb python python-pip imagemagick
msg "nsxiv + xrdb + python installed"

msg_start "Installing pywal16..."
if command -v wal > /dev/null 2>&1; then
    msg "pywal16 already installed"
else
    pip install --break-system-packages pywal16 2>/dev/null || \
        pip install pywal16 || \
        msg_error "pywal16 install failed, wallpaper selector will not work"
    msg "pywal16 installed"
fi

# Build tools (needed for suckless compilation and telescope-fzf-native)
msg_start "Installing build tools..."
pacman -S --needed --noconfirm \
    base-devel git
msg "Build tools installed"

# Shell and CLI tools
msg_start "Installing zsh and CLI tools..."
pacman -S --needed --noconfirm \
    zsh zoxide eza bat fzf
msg "zsh + CLI tools installed"

msg_start "Installing git-delta (optional)..."
if pacman -S --needed --noconfirm git-delta; then
    msg "git-delta installed"
else
    msg_error "git-delta unavailable, git will use default pager"
fi

# Editor and AI coding tools
msg_start "Installing Neovim and dependencies..."
pacman -S --needed --noconfirm \
    neovim ripgrep fd
msg "Neovim + dependencies installed"

msg_start "Installing opencode (optional)..."
if command -v opencode > /dev/null 2>&1; then
    msg "opencode already installed"
else
    if curl -fsSL https://opencode.ai/install | bash; then
        msg "opencode installed"
    else
        msg_error "opencode install failed, skipping"
    fi
fi

fi  # end BUILD_ONLY skip

# ============== STEP 3: BUILD SUCKLESS TOOLS ==============

SUCKLESS_DIR="${DOTFILES_DIR}/suckless"

if [[ "$SKIP_BUILD" == true ]] && [[ "$BUILD_ONLY" == false ]]; then
    echo ""
    echo -e "${PURPLE}[3/7] Skipping suckless builds (--skip-build)${NC}"
    echo ""
else

echo ""
echo -e "${PURPLE}[3/7] Building suckless tools...${NC}"
echo ""
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
    git clone "$repo" "$build_path"

    # Checkout specific version if provided
    if [[ -n "$version" ]]; then
        git -C "$build_path" checkout "$version"
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
    make -C "$build_path" clean install

    msg "Built and installed ${name}"
}

# Build dwm with xrdb support (sed-based, like st)
build_dwm() {
    local build_path="${BUILD_DIR}/dwm"

    msg_start "Building dwm..."

    if [[ -d "$build_path" ]]; then
        rm -rf "$build_path"
    fi
    git clone "https://git.suckless.org/dwm" "$build_path"
    git -C "$build_path" checkout "6.5"

    # Apply patches (01-07, skip 08-xrdb.diff — applied via sed below)
    if [[ -d "${SUCKLESS_DIR}/dwm/patches" ]]; then
        for p in "${SUCKLESS_DIR}/dwm/patches/"*.diff; do
            if [[ -f "$p" ]] && [[ "$(basename "$p")" != "08-xrdb.diff" ]]; then
                git -C "$build_path" apply "$p" 2>/dev/null || \
                    patch -d "$build_path" -p1 < "$p" 2>/dev/null || \
                    msg_error "Patch failed: $(basename "$p")"
            fi
        done
    fi

    # Copy config.h
    cp "${SUCKLESS_DIR}/dwm/config.h" "${build_path}/config.h"

    # --- xrdb patch via C code injection (runtime color reload) ---
    local dwmc="${build_path}/dwm.c"
    local drwc="${build_path}/drw.c"
    local drwh="${build_path}/drw.h"

    # Write C code fragments to temp files (avoids sed escaping nightmares)
    local tmpdir="${build_path}/xrdb-fragments"
    mkdir -p "$tmpdir"

    # Fragment: XRDB_LOAD_COLOR macro
    cat > "${tmpdir}/macro.c" << 'XRDB_MACRO'
#define XRDB_LOAD_COLOR(R,V)    if (XrmGetResource(xrdb, R, NULL, &type, &value) == True) { \
                                  if (value.addr != NULL && strnlen(value.addr, 8) == 7 && value.addr[0] == '#') { \
                                    int i = 1; \
                                    for (; i <= 6; i++) { \
                                      if (value.addr[i] < 48) break; \
                                      if (value.addr[i] > 57 && value.addr[i] < 65) break; \
                                      if (value.addr[i] > 70 && value.addr[i] < 97) break; \
                                      if (value.addr[i] > 102) break; \
                                    } \
                                    if (i == 7) { \
                                      strncpy(V, value.addr, 7); \
                                      V[7] = '\0'; \
                                    } \
                                  } \
                                }
XRDB_MACRO

    # Fragment: loadxrdb() function
    cat > "${tmpdir}/loadxrdb.c" << 'XRDB_LOAD'

void
loadxrdb(void)
{
	Display *display;
	char *resm;
	XrmDatabase xrdb;
	char *type;
	XrmValue value;

	display = XOpenDisplay(NULL);

	if (display != NULL) {
		resm = XResourceManagerString(display);

		if (resm != NULL) {
			xrdb = XrmGetStringDatabase(resm);

			if (xrdb != NULL) {
				XRDB_LOAD_COLOR("dwm.normfgcolor",     col_normfg);
				XRDB_LOAD_COLOR("dwm.normbgcolor",     col_normbg);
				XRDB_LOAD_COLOR("dwm.normbordercolor", col_normborder);
				XRDB_LOAD_COLOR("dwm.selfgcolor",      col_selfg);
				XRDB_LOAD_COLOR("dwm.selbgcolor",      col_selbg);
				XRDB_LOAD_COLOR("dwm.selbordercolor",  col_selborder);
				XRDB_LOAD_COLOR("dwm.statusfgcolor",   col_statusfg);
				XRDB_LOAD_COLOR("dwm.statusbgcolor",   col_statusbg);
				XRDB_LOAD_COLOR("dwm.tagsselfgcolor",  col_tagsselfg);
				XRDB_LOAD_COLOR("dwm.tagsselbgcolor",  col_tagsselbg);
				XRDB_LOAD_COLOR("dwm.tagsnormfgcolor", col_tagsnormfg);
				XRDB_LOAD_COLOR("dwm.tagsnormbgcolor", col_tagsnormbg);
				XRDB_LOAD_COLOR("dwm.infoselfgcolor",  col_infoselfg);
				XRDB_LOAD_COLOR("dwm.infoselbgcolor",  col_infoselbg);
				XRDB_LOAD_COLOR("dwm.infonormfgcolor", col_infonormfg);
				XRDB_LOAD_COLOR("dwm.infonormbgcolor", col_infonormbg);
			}
		}
	}

	XCloseDisplay(display);
}
XRDB_LOAD

    # Fragment: xrdb() keybind handler
    cat > "${tmpdir}/xrdb_handler.c" << 'XRDB_HANDLER'

void
xrdb(const Arg *arg)
{
	loadxrdb();
	int i;
	for (i = 0; i < LENGTH(colors); i++)
		scheme[i] = drw_scm_create(drw, colors[i], 3);
	focus(NULL);
	arrange(NULL);
}

XRDB_HANDLER

    # 1. Add #include <X11/Xresource.h> after Xproto.h
    sed -i '/#include <X11\/Xproto.h>/a #include <X11\/Xresource.h>' "$dwmc"

    # 2. Add XRDB_LOAD_COLOR macro after TEXTW line
    sed -i '/^#define TEXTW/r '"${tmpdir}/macro.c" "$dwmc"

    # 3. Add function declarations
    sed -i '/^static void manage(/i static void loadxrdb(void);' "$dwmc"
    sed -i '/^static void zoom(/i static void xrdb(const Arg *arg);' "$dwmc"

    # 4. Insert loadxrdb() after killclient() closing brace
    # Find the closing brace of killclient and insert after it
    # Use awk for reliable multi-line insertion after a specific function
    awk '
    /^killclient\(const Arg/ { in_killclient=1 }
    in_killclient && /^}/ { in_killclient=0; print; found=1; next }
    found && !inserted {
        while ((getline line < "'"${tmpdir}/loadxrdb.c"'") > 0) print line
        close("'"${tmpdir}/loadxrdb.c"'")
        inserted=1
    }
    { print }
    ' "$dwmc" > "${dwmc}.tmp" && mv "${dwmc}.tmp" "$dwmc"

    # 5. Insert xrdb() handler before zoom()
    awk '
    /^zoom\(const Arg/ && !inserted {
        while ((getline line < "'"${tmpdir}/xrdb_handler.c"'") > 0) print line
        close("'"${tmpdir}/xrdb_handler.c"'")
        inserted=1
    }
    { print }
    ' "$dwmc" > "${dwmc}.tmp" && mv "${dwmc}.tmp" "$dwmc"

    # 6. Add XrmInitialize() + loadxrdb() in main() before setup()
    sed -i '/checkotherwm();/a \\tXrmInitialize();\n\tloadxrdb();' "$dwmc"

    # 7. Fix drw.c: drop const from drw_scm_create parameter
    sed -i 's/drw_scm_create(Drw \*drw, const char \*clrnames\[\]/drw_scm_create(Drw *drw, char *clrnames[]/' "$drwc"

    # 8. Fix drw.h: drop const from drw_scm_create declaration
    sed -i 's/Clr \*drw_scm_create(Drw \*drw, const char \*clrnames\[\]/Clr *drw_scm_create(Drw *drw, char *clrnames[]/' "$drwh"

    # Cleanup
    rm -rf "$tmpdir"

    msg "Applied xrdb modifications (sed)"

    # Build and install
    make -C "$build_path" clean install

    msg "Built and installed dwm"
}

# Build st last — rebuilding st replaces the running terminal binary,
# which can kill the session. Everything else should complete first.
build_dwm
build_suckless "dmenu"     "https://git.suckless.org/dmenu"     "5.3"
build_suckless "dwmblocks" "https://github.com/torrinfail/dwmblocks.git" ""

# Build st with sed-based customization of config.def.h
build_st() {
    local build_path="${BUILD_DIR}/st"

    msg_start "Building st..."

    if [[ -d "$build_path" ]]; then
        rm -rf "$build_path"
    fi
    git clone "https://git.suckless.org/st" "$build_path"
    git -C "$build_path" checkout "0.9.2"

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
    sed -i 's|^static char \*font = .*|static char *font = "JetBrainsMono Nerd Font:pixelsize=16:antialias=true:autohint=true";|' "$conf"

    # Border
    sed -i 's|^static int borderpx.*|static int borderpx = 2;|' "$conf"

    # Tab width
    sed -i 's|^unsigned int tabspaces.*|unsigned int tabspaces = 4;|' "$conf"

    # Disable bell
    sed -i 's|^static int bellvolume.*|static int bellvolume = 0;|' "$conf"

    # Alpha (transparency — requires picom compositor)
    sed -i 's|^float alpha =.*|float alpha = 0.85;|' "$conf"

    # Catppuccin Mocha colors — replace the entire colorname array
    # Reference: https://github.com/catppuccin/st
    sed -i '/^static const char \*colorname/,/^};/c\
static const char *colorname[] = {\
	/* 8 normal colors */\
	"#45475a", /* black   (Surface1)  */\
	"#f38ba8", /* red     (Red)       */\
	"#a6e3a1", /* green   (Green)     */\
	"#f9e2af", /* yellow  (Yellow)    */\
	"#89b4fa", /* blue    (Blue)      */\
	"#f5c2e7", /* magenta (Pink)      */\
	"#94e2d5", /* cyan    (Teal)      */\
	"#bac2de", /* white   (Subtext1)  */\
\
	/* 8 bright colors */\
	"#585b70", /* bright black   (Surface2)  */\
	"#f38ba8", /* bright red     (Red)       */\
	"#a6e3a1", /* bright green   (Green)     */\
	"#f9e2af", /* bright yellow  (Yellow)    */\
	"#89b4fa", /* bright blue    (Blue)      */\
	"#f5c2e7", /* bright magenta (Pink)      */\
	"#94e2d5", /* bright cyan    (Teal)      */\
	"#a6adc8", /* bright white   (Subtext0)  */\
\
	[255] = 0,\
\
	/* special colors (256+) */\
	"#f5e0dc", /* 256: cursor       (Rosewater) */\
	"#cdd6f4", /* 257: reverse cursor (Text)    */\
	"#cdd6f4", /* 258: foreground    (Text)     */\
	"#1e1e2e", /* 259: background    (Base)     */\
};' "$conf"

    # Point default fg/bg/cursor to the correct indices (unchanged from stock)
    sed -i 's|^unsigned int defaultfg.*|unsigned int defaultfg = 258;|' "$conf"
    sed -i 's|^unsigned int defaultbg.*|unsigned int defaultbg = 259;|' "$conf"
    sed -i 's|^static unsigned int defaultrcs.*|static unsigned int defaultrcs = 257;|' "$conf"
    sed -i 's|^unsigned int defaultcs.*|unsigned int defaultcs = 256;|' "$conf"

    # Build in the temp dir, then install with cp to avoid `make install`
    # doing rm + cp which can kill a running st session.
    make -C "$build_path" clean st
    cp -f "$build_path/st" /usr/local/bin/st

    msg "Built and installed st"
}

build_st

# Cleanup build directory
rm -rf "$BUILD_DIR"

fi  # end SKIP_BUILD check

# ============== STEP 4: SYMLINK DOTFILES ==============

echo ""
echo -e "${PURPLE}[4/7] Linking dotfiles...${NC}"
echo ""

HOME_SRC="${DOTFILES_DIR}/home"

# Symlink everything from arch/home/ into $HOME
if [[ -d "$HOME_SRC" ]]; then
    # .xinitrc
    if [[ -f "${HOME_SRC}/.xinitrc" ]]; then
        ln -sf "${HOME_SRC}/.xinitrc" ~/.xinitrc
        msg "Linked .xinitrc"
    fi

    # .zshrc
    if [[ -f "${HOME_SRC}/.zshrc" ]]; then
        ln -sf "${HOME_SRC}/.zshrc" ~/.zshrc
        msg "Linked .zshrc"
    fi

    # .gitconfig (aliases, merge, diff settings — no personal info)
    if [[ -f "${HOME_SRC}/.gitconfig" ]]; then
        ln -sf "${HOME_SRC}/.gitconfig" ~/.gitconfig
        msg "Linked .gitconfig"
    fi

    # .gitconfig-delta (conditional delta pager config)
    if [[ -f "${HOME_SRC}/.gitconfig-delta" ]]; then
        ln -sf "${HOME_SRC}/.gitconfig-delta" ~/.gitconfig-delta
        msg "Linked .gitconfig-delta"
    fi

    # Git user identity (interactive, skip if already configured)
    if git config --global user.name > /dev/null 2>&1; then
        msg "Git user already configured ($(git config --global user.name))"
    else
        echo ""
        echo -e "  ${YELLOW}Git needs your identity for commits:${NC}"
        read -rp "    Name:  " git_name
        read -rp "    Email: " git_email
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        msg "Git user configured: ${git_name} <${git_email}>"
    fi

    # .zsh/ directory (individual module files)
    if [[ -d "${HOME_SRC}/.zsh" ]]; then
        mkdir -p ~/.zsh
        for zsh_file in "${HOME_SRC}/.zsh/"*.zsh; do
            if [[ -f "$zsh_file" ]]; then
                ln -sf "$zsh_file" ~/.zsh/"$(basename "$zsh_file")"
            fi
        done
        msg "Linked .zsh/ modules"
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

# Symlink wallpaper selector scripts to PATH
if [[ -d "${HOME_SRC}/.local/bin" ]]; then
    mkdir -p /usr/local/bin
    for script in "${HOME_SRC}/.local/bin/"*; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
            ln -sf "$script" /usr/local/bin/"$(basename "$script")"
        fi
    done
    msg "Linked user scripts (set-wallpaper, wal-restore)"
fi

# Create wallpapers directory
mkdir -p ~/wallpapers
msg "Created ~/wallpapers directory"

# ============== STEP 5: INSTALL OH-MY-POSH ==============

if [[ "$BUILD_ONLY" == true ]]; then
    echo -e "${PURPLE}[5/7] Skipping oh-my-posh (--build-only)${NC}"
else

echo ""
echo -e "${PURPLE}[5/7] Installing oh-my-posh...${NC}"
echo ""

if command -v oh-my-posh > /dev/null 2>&1; then
    msg "oh-my-posh already installed"
else
    msg_start "Downloading oh-my-posh binary..."
    OMP_INSTALL_DIR="/usr/local/bin"
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64) OMP_ARCH="arm64" ;;
        x86_64)  OMP_ARCH="amd64" ;;
        armv7l)  OMP_ARCH="arm" ;;
        *)       OMP_ARCH="$ARCH" ;;
    esac
    curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${OMP_ARCH}" -o "${OMP_INSTALL_DIR}/oh-my-posh"
    chmod +x "${OMP_INSTALL_DIR}/oh-my-posh"
    msg "oh-my-posh installed"
fi

fi  # end BUILD_ONLY skip

# ============== STEP 6: SET ZSH AS DEFAULT SHELL ==============

if [[ "$BUILD_ONLY" == true ]]; then
    echo -e "${PURPLE}[6/7] Skipping zsh default shell (--build-only)${NC}"
else

echo ""
echo -e "${PURPLE}[6/7] Setting zsh as default shell...${NC}"
echo ""

if [[ "$(basename "$SHELL")" == "zsh" ]]; then
    msg "zsh is already the default shell"
else
    msg_start "Changing default shell to zsh..."
    chsh -s /bin/zsh
    msg "Default shell set to zsh"
fi

fi  # end BUILD_ONLY skip

# ============== STEP 7: NEOVIM PLUGIN BOOTSTRAP ==============

if [[ "$BUILD_ONLY" == true ]]; then
    echo -e "${PURPLE}[7/7] Skipping Neovim plugins (--build-only)${NC}"
else

echo ""
echo -e "${PURPLE}[7/7] Bootstrapping Neovim plugins...${NC}"
echo ""

# Run nvim headless to trigger lazy.nvim plugin installation
msg_start "Installing Neovim plugins (this may take a moment)..."
nvim --headless "+Lazy! sync" +qa || true
msg "Neovim plugins installed"

fi  # end BUILD_ONLY skip

echo ""
msg "Arch Linux setup complete"
echo ""
