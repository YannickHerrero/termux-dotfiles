#!/bin/bash
set -euo pipefail
#######################################################
#  Build Check — Local Suckless Build Validation
#
#  Compiles dwm, st, dmenu, and dwmblocks locally to
#  catch build errors before pushing. Nothing is
#  installed — only compilation is verified.
#
#  Since this dev machine is aarch64 Arch Linux (same
#  as the Termux proot guest), the builds are native
#  and identical to what runs on the phone.
#
#  Usage:
#    bash build-check.sh              # Build all
#    bash build-check.sh dwm st       # Build specific tools
#    bash build-check.sh --clean      # Remove cached clones
#
#  Upstream clones are cached in /tmp between runs.
#  They persist until reboot or --clean.
#######################################################

# ============== CONFIGURATION ==============

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUCKLESS_DIR="${SCRIPT_DIR}/arch/suckless"
BUILD_DIR="/tmp/suckless-build-check"
ALL_TOOLS=(dwm st dmenu dwmblocks)

# ============== COLORS ==============

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
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

# ============== ARGUMENT PARSING ==============

if [[ "${1:-}" == "--clean" ]]; then
    echo -e "${PURPLE}Cleaning cached build directory...${NC}"
    rm -rf "$BUILD_DIR"
    msg "Removed ${BUILD_DIR}"
    exit 0
fi

# Determine which tools to build
if [[ $# -gt 0 ]]; then
    TOOLS=("$@")
else
    TOOLS=("${ALL_TOOLS[@]}")
fi

# Validate tool names
for tool in "${TOOLS[@]}"; do
    valid=false
    for known in "${ALL_TOOLS[@]}"; do
        if [[ "$tool" == "$known" ]]; then
            valid=true
            break
        fi
    done
    if [[ "$valid" == false ]]; then
        msg_error "Unknown tool: ${tool}"
        echo "  Available: ${ALL_TOOLS[*]}"
        exit 1
    fi
done

# ============== CLONE HELPER ==============

# Clone or reuse a cached upstream repo.
# Usage: clone_or_cache <name> <repo_url> [version]
clone_or_cache() {
    local name=$1
    local repo=$2
    local version=${3:-""}
    local cache_path="${BUILD_DIR}/cache/${name}"
    local build_path="${BUILD_DIR}/${name}"

    # Clone into cache if not present
    if [[ ! -d "$cache_path" ]]; then
        msg_start "Cloning ${name} upstream..."
        git clone "$repo" "$cache_path" 2>&1
    fi

    # Copy cache to build directory (always fresh build tree)
    rm -rf "$build_path"
    cp -r "$cache_path" "$build_path"

    # Checkout specific version
    if [[ -n "$version" ]]; then
        git -C "$build_path" checkout --quiet "$version"
    fi
}

# Run make and show output only on failure.
# Usage: run_make <build_path> <targets...>
run_make() {
    local build_path=$1
    shift
    local log="${build_path}/build.log"

    if ! make -C "$build_path" "$@" > "$log" 2>&1; then
        echo ""
        cat "$log"
        echo ""
        return 1
    fi
}

# ============== BUILD: DWM ==============

build_dwm() {
    local build_path="${BUILD_DIR}/dwm"

    msg_start "Building dwm..."

    rm -rf "$build_path"
    cp -r "${SUCKLESS_DIR}/dwm" "$build_path"
    run_make "$build_path" clean dwm

    msg "dwm compiled successfully"
}

# ============== BUILD: ST ==============

build_st() {
    clone_or_cache "st" "https://git.suckless.org/st" "0.9.2"

    local build_path="${BUILD_DIR}/st"

    msg_start "Building st..."

    # Apply patches
    if [[ -d "${SUCKLESS_DIR}/st/patches" ]]; then
        for p in "${SUCKLESS_DIR}/st/patches/"*.diff; do
            if [[ -f "$p" ]]; then
                if ! git -C "$build_path" apply "$p" 2>/dev/null; then
                    if ! patch -d "$build_path" -p1 < "$p" > /dev/null 2>&1; then
                        msg_error "Patch failed: $(basename "$p")"
                        return 1
                    fi
                fi
            fi
        done
    fi

    # Customize config.def.h via sed (mirrors arch/setup.sh build_st)
    local conf="${build_path}/config.def.h"

    # Font
    sed -i 's|^static char \*font = .*|static char *font = "JetBrainsMono Nerd Font:pixelsize=16:antialias=true:autohint=true";|' "$conf"

    # Border
    sed -i 's|^static int borderpx.*|static int borderpx = 2;|' "$conf"

    # Tab width
    sed -i 's|^unsigned int tabspaces.*|unsigned int tabspaces = 4;|' "$conf"

    # Disable bell
    sed -i 's|^static int bellvolume.*|static int bellvolume = 0;|' "$conf"

    # Alpha (transparency)
    sed -i 's|^float alpha =.*|float alpha = 0.85;|' "$conf"

    # Catppuccin Mocha colors — replace the entire colorname array
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

    # Point default fg/bg/cursor to the correct indices
    sed -i 's|^unsigned int defaultfg.*|unsigned int defaultfg = 258;|' "$conf"
    sed -i 's|^unsigned int defaultbg.*|unsigned int defaultbg = 259;|' "$conf"
    sed -i 's|^static unsigned int defaultrcs.*|static unsigned int defaultrcs = 257;|' "$conf"
    sed -i 's|^unsigned int defaultcs.*|unsigned int defaultcs = 256;|' "$conf"

    run_make "$build_path" clean st

    msg "st compiled successfully"
}

# ============== BUILD: DMENU ==============

build_dmenu() {
    clone_or_cache "dmenu" "https://git.suckless.org/dmenu" "5.3"

    local build_path="${BUILD_DIR}/dmenu"

    msg_start "Building dmenu..."

    # Apply patches
    if [[ -d "${SUCKLESS_DIR}/dmenu/patches" ]]; then
        for p in "${SUCKLESS_DIR}/dmenu/patches/"*.diff; do
            if [[ -f "$p" ]]; then
                if ! git -C "$build_path" apply "$p" 2>/dev/null; then
                    if ! patch -d "$build_path" -p1 < "$p" > /dev/null 2>&1; then
                        msg_error "Patch failed: $(basename "$p")"
                        return 1
                    fi
                fi
            fi
        done
    fi

    # Copy config.h
    if [[ -f "${SUCKLESS_DIR}/dmenu/config.h" ]]; then
        cp "${SUCKLESS_DIR}/dmenu/config.h" "${build_path}/config.h"
    fi

    run_make "$build_path" clean dmenu

    msg "dmenu compiled successfully"
}

# ============== BUILD: DWMBLOCKS ==============

build_dwmblocks() {
    clone_or_cache "dwmblocks" "https://github.com/torrinfail/dwmblocks.git" ""

    local build_path="${BUILD_DIR}/dwmblocks"

    msg_start "Building dwmblocks..."

    # Apply patches
    if [[ -d "${SUCKLESS_DIR}/dwmblocks/patches" ]]; then
        for p in "${SUCKLESS_DIR}/dwmblocks/patches/"*.diff; do
            if [[ -f "$p" ]]; then
                if ! git -C "$build_path" apply "$p" 2>/dev/null; then
                    if ! patch -d "$build_path" -p1 < "$p" > /dev/null 2>&1; then
                        msg_error "Patch failed: $(basename "$p")"
                        return 1
                    fi
                fi
            fi
        done
    fi

    # Copy config.h
    if [[ -f "${SUCKLESS_DIR}/dwmblocks/config.h" ]]; then
        cp "${SUCKLESS_DIR}/dwmblocks/config.h" "${build_path}/config.h"
    fi

    run_make "$build_path" clean dwmblocks

    msg "dwmblocks compiled successfully"
}

# ============== MAIN ==============

echo ""
echo -e "${BOLD}Suckless build check${NC}"
echo -e "Building: ${TOOLS[*]}"
echo ""

mkdir -p "${BUILD_DIR}/cache"

passed=0
failed=0
failed_tools=()

for tool in "${TOOLS[@]}"; do
    if "build_${tool}"; then
        ((passed++)) || true
    else
        ((failed++)) || true
        failed_tools+=("$tool")
    fi
done

# ============== SUMMARY ==============

echo ""
if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All ${passed} builds passed${NC}"
else
    echo -e "${RED}${BOLD}${failed} build(s) failed:${NC} ${failed_tools[*]}"
    echo -e "${GREEN}${passed} build(s) passed${NC}"
fi
echo ""

exit "$failed"
