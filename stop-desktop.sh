#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Stop Desktop Session
#
#  Kills Termux-X11, PulseAudio, and any remaining
#  desktop processes.
#
#  Usage: bash ~/stop-desktop.sh
#######################################################

echo "Stopping desktop session..."

pkill -9 -f "termux.x11" 2>/dev/null || true
pkill -9 -f "pulseaudio" 2>/dev/null || true
pkill -9 -f "dbus" 2>/dev/null || true

echo "Desktop stopped."
