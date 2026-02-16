#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Termux Dotfiles - Hacklab Cleanup
#
#  Removes artifacts left by a previous hacklab
#  installation (termux-hacklab) so you can start
#  fresh with install.sh.
#
#  Safe to run multiple times (idempotent).
#  Does NOT remove shared packages (x11-repo,
#  termux-x11, pulseaudio, mesa, git, wget, curl).
#
#  Usage: bash cleanup.sh
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=8
CURRENT_STEP=0

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# ============== UTILITY FUNCTIONS ==============

update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    local bar="${GREEN}"
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    bar+="${GRAY}"
    for ((i = 0; i < empty; i++)); do bar+="░"; done
    bar+="${NC}"

    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${bar} ${WHITE}${percent}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

remove_file() {
    local filepath=$1
    local label=${2:-$filepath}

    if [[ -e "$filepath" ]]; then
        rm -rf "$filepath"
        echo -e "  ${GREEN}✓${NC} Removed ${label}"
    else
        echo -e "  ${GRAY}-${NC} Not found: ${label} (skipped)"
    fi
}

remove_symlink() {
    local filepath=$1
    local label=${2:-$filepath}

    if [[ -L "$filepath" ]]; then
        rm -f "$filepath"
        echo -e "  ${GREEN}✓${NC} Removed symlink ${label}"
    else
        echo -e "  ${GRAY}-${NC} Not found: ${label} (skipped)"
    fi
}

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ┌──────────────────────────────────────┐"
    echo "  │                                      │"
    echo "  │    Termux Dotfiles - Cleanup          │"
    echo "  │    Remove hacklab artifacts           │"
    echo "  │                                      │"
    echo "  └──────────────────────────────────────┘"
    echo -e "${NC}"
    echo ""
}

# ============== STEP 1: KILL RUNNING PROCESSES ==============

step_kill_processes() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Killing hacklab processes...${NC}"
    echo ""

    local killed=0

    for proc in xfce4-session xfwm4 xfce4-panel xfdesktop xfce4-terminal thunar mousepad; do
        if pgrep -x "$proc" > /dev/null 2>&1; then
            pkill -9 -x "$proc" 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Killed ${proc}"
            killed=$((killed + 1))
        fi
    done

    for proc in dbus-daemon pulseaudio; do
        if pgrep -x "$proc" > /dev/null 2>&1; then
            pkill -9 -x "$proc" 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Killed ${proc}"
            killed=$((killed + 1))
        fi
    done

    if pgrep -f "termux.x11" > /dev/null 2>&1; then
        pkill -9 -f "termux.x11" 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} Killed termux-x11"
        killed=$((killed + 1))
    fi

    if [[ $killed -eq 0 ]]; then
        echo -e "  ${GRAY}-${NC} No hacklab processes running"
    fi
}

# ============== STEP 2: REMOVE HACKLAB SCRIPTS ==============

step_remove_scripts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing hacklab launcher scripts...${NC}"
    echo ""

    remove_file ~/start-hacklab.sh
    remove_file ~/stop-hacklab.sh
    remove_file ~/hacktools.sh
}

# ============== STEP 3: REMOVE DESKTOP SHORTCUTS ==============

step_remove_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing desktop shortcuts...${NC}"
    echo ""

    remove_file ~/Desktop "~/Desktop/ directory"
}

# ============== STEP 4: REMOVE GPU CONFIG ==============

step_remove_gpu_config() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing hacklab GPU config...${NC}"
    echo ""

    remove_file ~/.config/hacklab-gpu.sh

    # Remove the source line from .bashrc
    if [[ -f ~/.bashrc ]]; then
        if grep -q "hacklab-gpu.sh" ~/.bashrc 2>/dev/null; then
            sed -i '/hacklab-gpu\.sh/d' ~/.bashrc
            echo -e "  ${GREEN}✓${NC} Removed hacklab-gpu.sh source line from ~/.bashrc"
        else
            echo -e "  ${GRAY}-${NC} No hacklab-gpu.sh reference in ~/.bashrc"
        fi
    fi
}

# ============== STEP 5: REMOVE WINE SYMLINKS ==============

step_remove_wine_symlinks() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing Wine symlinks...${NC}"
    echo ""

    local prefix="/data/data/com.termux/files/usr/bin"
    remove_symlink "${prefix}/wine"
    remove_symlink "${prefix}/winecfg"
}

# ============== STEP 6: UNINSTALL HACKLAB PACKAGES ==============

step_uninstall_packages() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Uninstalling hacklab-only packages...${NC}"
    echo ""

    # Packages installed exclusively by the hacklab
    local hacklab_pkgs=(
        # XFCE4 desktop environment
        xfce4
        xfce4-terminal
        thunar
        mousepad
        xfdesktop
        xfwm4
        xfce4-session
        xfce4-panel
        xfce4-settings
        # Editors / browsers (Termux-native)
        code-oss
        firefox
        # Security tools
        nmap
        netcat-openbsd
        whois
        dnsutils
        tracepath
        hydra
        john
        sqlmap
        # Wine / Hangover
        hangover-wine
        hangover-wowbox64
    )

    local removed=0
    for pkg in "${hacklab_pkgs[@]}"; do
        if dpkg -s "$pkg" > /dev/null 2>&1; then
            pkg uninstall -y "$pkg" > /dev/null 2>&1 || true
            echo -e "  ${GREEN}✓${NC} Uninstalled ${pkg}"
            removed=$((removed + 1))
        fi
    done

    if [[ $removed -eq 0 ]]; then
        echo -e "  ${GRAY}-${NC} No hacklab packages found"
    else
        echo -e "  ${BLUE}i${NC} Removed ${removed} package(s)"
    fi
}

# ============== STEP 7: REMOVE TUR-REPO ==============

step_remove_tur_repo() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing tur-repo...${NC}"
    echo ""

    if dpkg -s tur-repo > /dev/null 2>&1; then
        pkg uninstall -y tur-repo > /dev/null 2>&1 || true
        echo -e "  ${GREEN}✓${NC} Uninstalled tur-repo"
    else
        echo -e "  ${GRAY}-${NC} tur-repo not installed (skipped)"
    fi
}

# ============== STEP 8: CLEANUP & PIP PACKAGES ==============

step_final_cleanup() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Final cleanup...${NC}"
    echo ""

    # Remove pip packages installed by hacklab
    if command -v pip > /dev/null 2>&1; then
        for pkg in requests beautifulsoup4; do
            if pip show "$pkg" > /dev/null 2>&1; then
                pip uninstall -y "$pkg" > /dev/null 2>&1 || true
                echo -e "  ${GREEN}✓${NC} Uninstalled pip package: ${pkg}"
            fi
        done
    else
        echo -e "  ${GRAY}-${NC} pip not found (skipping Python cleanup)"
    fi

    # Autoremove orphaned dependencies
    pkg autoclean > /dev/null 2>&1 || true
    echo -e "  ${GREEN}✓${NC} Package cache cleaned"

    (apt autoremove -y > /dev/null 2>&1) || true
    echo -e "  ${GREEN}✓${NC} Orphaned dependencies removed"
}

# ============== COMPLETION ==============

show_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "  ┌───────────────────────────────────────────┐"
    echo "  │                                           │"
    echo "  │       Cleanup complete!                   │"
    echo "  │                                           │"
    echo "  └───────────────────────────────────────────┘"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}  Hacklab artifacts have been removed.${NC}"
    echo -e "${WHITE}  Shared packages (x11-repo, termux-x11, pulseaudio,${NC}"
    echo -e "${WHITE}  mesa, git, wget, curl) were kept intact.${NC}"
    echo ""
    echo -e "${WHITE}  Next step — install the suckless desktop:${NC}"
    echo -e "    ${GREEN}bash install.sh${NC}"
    echo ""
}

# ============== MAIN ==============

main() {
    show_banner

    echo -e "${WHITE}  This will remove artifacts from a previous hacklab${NC}"
    echo -e "${WHITE}  installation, preparing your Termux for a clean setup.${NC}"
    echo ""
    echo -e "${GRAY}  The following will be kept:${NC}"
    echo -e "${GRAY}    x11-repo, termux-x11, pulseaudio, mesa drivers,${NC}"
    echo -e "${GRAY}    git, wget, curl${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start cleanup, or Ctrl+C to cancel...${NC}"
    read -r

    step_kill_processes
    step_remove_scripts
    step_remove_desktop
    step_remove_gpu_config
    step_remove_wine_symlinks
    step_uninstall_packages
    step_remove_tur_repo
    step_final_cleanup
    show_completion
}

# ============== RUN ==============
main
