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

# Kill proot-internal desktop processes (only if proot-distro + Arch are available)
if command -v proot-distro > /dev/null 2>&1 \
    && proot-distro list 2>/dev/null | grep -q "archlinux.*Installed"; then
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
