#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Stop Desktop Session
#
#  Kills Termux-X11, PulseAudio, and any remaining
#  desktop processes (both host and proot-internal).
#
#  Usage: bash ~/stop-desktop.sh
#######################################################

echo "Stopping desktop session..."

is_arch_installed() {
    local rootfs_dir="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs/archlinux"

    if ! command -v proot-distro > /dev/null 2>&1; then
        return 1
    fi

    if proot-distro login archlinux -- true > /dev/null 2>&1; then
        return 0
    fi

    [[ -d "$rootfs_dir" ]]
}

# Kill proot-internal desktop processes (only if proot-distro + Arch are available)
if is_arch_installed; then
    proot-distro login archlinux -- pkill -9 dwm 2>/dev/null || true
    proot-distro login archlinux -- pkill -9 picom 2>/dev/null || true
    proot-distro login archlinux -- pkill -9 dunst 2>/dev/null || true
    proot-distro login archlinux -- pkill -9 dwmblocks 2>/dev/null || true
fi

# Kill Termux host processes
pkill -9 -f "termux.x11" 2>/dev/null || true
pkill -9 -f "pulseaudio" 2>/dev/null || true
pkill -9 -x "dbus-daemon" 2>/dev/null || true

echo "Desktop stopped."
