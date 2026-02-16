#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Termux Dotfiles - Host Installer
#
#  Sets up the Termux host environment:
#    - GPU acceleration (Mesa Zink / Turnip)
#    - Termux-X11 display server
#    - PulseAudio
#    - proot-distro with Arch Linux
#    - Launches Arch setup script
#
#  Usage: bash install.sh
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=7
CURRENT_STEP=0
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

run_cmd() {
    local message=$1
    shift

    echo -e "  ${YELLOW}→${NC} ${message}"
    "${@}"
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}

    echo -e "  ${YELLOW}→${NC} Installing ${name} (${pkg})"
    pkg install -y "$pkg"
    echo -e "  ${GREEN}✓${NC} Installed ${name}"
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

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ┌──────────────────────────────────────┐"
    echo "  │                                      │"
    echo "  │    Termux Suckless Desktop Setup     │"
    echo "  │    dwm + st + dmenu + dwmblocks      │"
    echo "  │                                      │"
    echo "  └──────────────────────────────────────┘"
    echo -e "${NC}"
    echo ""
}

# ============== DEVICE DETECTION ==============

detect_device() {
    echo -e "${PURPLE}[*] Detecting device...${NC}"
    echo ""

    local device_model
    local device_brand
    local android_version
    local gpu_vendor

    device_model=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    device_brand=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    android_version=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    gpu_vendor=$(getprop ro.hardware.egl 2>/dev/null || echo "")

    echo -e "  ${GREEN}Device:${NC}  ${WHITE}${device_brand} ${device_model}${NC}"
    echo -e "  ${GREEN}Android:${NC} ${WHITE}${android_version}${NC}"

    # Determine GPU driver
    if [[ "$gpu_vendor" == *"adreno"* ]] \
        || [[ "${device_brand,,}" == *"samsung"* ]] \
        || [[ "${device_brand,,}" == *"oneplus"* ]] \
        || [[ "${device_brand,,}" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}GPU:${NC}     ${WHITE}Adreno (Qualcomm) - Turnip driver${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}GPU:${NC}     ${WHITE}Software rendering (swrast)${NC}"
    fi

    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============

step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""

    run_cmd "Updating package lists..." pkg update -y

    run_cmd "Upgrading installed packages..." pkg upgrade -y
}

# ============== STEP 2: ADD REPOSITORIES ==============

step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""

    install_pkg "x11-repo" "X11 Repository"
}

# ============== STEP 3: SETUP SHELL (ZSH + OH MY POSH) ==============

step_shell() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Setting up Zsh shell...${NC}"
    echo ""

    bash "${DOTFILES_DIR}/termux/setup-shell.sh"
}

# ============== STEP 4: INSTALL DISPLAY + AUDIO ==============

step_display_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing display server and audio...${NC}"
    echo ""

    install_pkg "termux-x11-nightly" "Termux-X11 Display Server"
    install_pkg "xorg-xrandr" "XRandR (Display Settings)"
    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

# ============== STEP 5: INSTALL GPU DRIVERS ==============

step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU acceleration...${NC}"
    echo ""

    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"

    if [[ "$GPU_DRIVER" == "freedreno" ]]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno GPU Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
    fi

    install_pkg "vulkan-loader-android" "Vulkan Loader"

    # GPU config is sourced from ~/.zshrc (installed by step_shell)
    # Also keep a bashrc fallback for non-interactive sessions
    mkdir -p ~/.config
    safe_copy "${DOTFILES_DIR}/config/gpu.sh" ~/.config/gpu.sh
    if ! grep -q "config/gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/gpu.sh 2>/dev/null' >> ~/.bashrc
    fi

    echo -e "  ${GREEN}✓${NC} GPU acceleration configured"
}

# ============== STEP 6: INSTALL PROOT-DISTRO + ARCH ==============

step_proot_arch() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing proot-distro and Arch Linux...${NC}"
    echo ""

    install_pkg "proot-distro" "proot-distro"

    # Install Arch Linux if not already present
    if proot-distro list 2>/dev/null | grep -q "archlinux.*Installed"; then
        echo -e "  ${GREEN}✓${NC} Arch Linux already installed"
    else
        run_cmd "Installing Arch Linux rootfs..." proot-distro install archlinux
        echo -e "  ${GREEN}✓${NC} Arch Linux rootfs installed"
    fi
}

# ============== STEP 7: RUN ARCH SETUP ==============

step_arch_setup() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Setting up Arch Linux environment...${NC}"
    echo ""

    if ! command -v proot-distro > /dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} proot-distro is not installed"
        return 1
    fi

    if ! proot-distro list 2>/dev/null | grep -q "archlinux.*Installed"; then
        echo -e "  ${RED}✗${NC} Arch Linux rootfs not found"
        echo -e "    Install it with: ${YELLOW}proot-distro install archlinux${NC}"
        return 1
    fi

    # Copy arch/ directory into the Arch rootfs
    local arch_rootfs
    arch_rootfs="$(proot-distro list 2>/dev/null | grep -A1 "archlinux" | grep -oP '/[^ ]+' | head -1 || true)"
    if [[ -z "$arch_rootfs" ]]; then
        # Fallback to default path
        arch_rootfs="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/archlinux"
    fi

    echo -e "  ${YELLOW}⏳${NC} Copying dotfiles into Arch rootfs..."
    local arch_home="${arch_rootfs}/root"
    mkdir -p "${arch_home}/.dotfiles"
    cp -r "${DOTFILES_DIR}/arch/"* "${arch_home}/.dotfiles/"
    echo -e "  ${GREEN}✓${NC} Dotfiles copied"

    # Run the Arch setup script inside proot
    proot-distro login archlinux -- bash /root/.dotfiles/setup.sh

    echo -e "  ${GREEN}✓${NC} Arch Linux environment ready"
}

# ============== INSTALL LAUNCHER SCRIPTS ==============

install_launchers() {
    echo -e "${PURPLE}[*] Installing launcher scripts...${NC}"
    echo ""

    safe_copy "${DOTFILES_DIR}/start-desktop.sh" ~/start-desktop.sh
    chmod +x ~/start-desktop.sh
    echo -e "  ${GREEN}✓${NC} ~/start-desktop.sh installed"

    safe_copy "${DOTFILES_DIR}/stop-desktop.sh" ~/stop-desktop.sh
    chmod +x ~/stop-desktop.sh
    echo -e "  ${GREEN}✓${NC} ~/stop-desktop.sh installed"
}

# ============== COMPLETION ==============

show_completion() {
    echo ""
    echo -e "${GREEN}"
    echo "  ┌───────────────────────────────────────────┐"
    echo "  │                                           │"
    echo "  │       Installation complete!              │"
    echo "  │                                           │"
    echo "  └───────────────────────────────────────────┘"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}  Start the desktop:${NC}"
    echo -e "    ${GREEN}bash ~/start-desktop.sh${NC}"
    echo ""
    echo -e "${WHITE}  Stop the desktop:${NC}"
    echo -e "    ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo ""
    echo -e "${GRAY}  Tip: Open the Termux-X11 app before starting the desktop.${NC}"
    echo -e "${GRAY}  Tip: Restart Termux to switch to your new Zsh shell.${NC}"
    echo ""
}

# ============== MAIN ==============

main() {
    show_banner

    echo -e "${WHITE}  This will install a minimal tiling desktop on your phone:${NC}"
    echo -e "${GRAY}    dwm + st + dmenu + dwmblocks${NC}"
    echo -e "${GRAY}    Firefox, ranger, picom, dunst${NC}"
    echo -e "${GRAY}    Zsh + Starship prompt (Termux shell)${NC}"
    echo -e "${GRAY}    GPU acceleration via Mesa Zink/Turnip${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start, or Ctrl+C to cancel...${NC}"
    read -r

    detect_device
    step_update
    step_repos
    step_shell
    step_display_audio
    step_gpu
    step_proot_arch
    step_arch_setup
    install_launchers
    show_completion
}

# ============== RUN ==============
main
