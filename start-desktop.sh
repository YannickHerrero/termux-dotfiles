#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
#######################################################
#  Start Desktop Session
#
#  Launches Termux-X11, PulseAudio, and dwm inside
#  the Arch Linux proot environment.
#
#  Usage: bash ~/start-desktop.sh
#######################################################

# ============== COLORS ==============
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

# ============== CLEANUP ==============
echo ""
echo -e "${WHITE}Starting desktop session...${NC}"
echo ""

echo -e "  ${YELLOW}⏳${NC} Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null || true
pkill -9 -f "pulseaudio" 2>/dev/null || true
sleep 0.5

# ============== GPU ==============
echo -e "  ${YELLOW}⏳${NC} Loading GPU config..."
source ~/.config/gpu.sh 2>/dev/null || true

# ============== AUDIO ==============
unset PULSE_SERVER
echo -e "  ${YELLOW}⏳${NC} Starting audio server..."
pulseaudio --start --exit-idle-time=-1 2>/dev/null
sleep 0.5
if ! pactl list modules short 2>/dev/null | grep -q module-native-protocol-tcp; then
    pactl load-module module-native-protocol-tcp \
        auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null || true
fi
export PULSE_SERVER=127.0.0.1
echo -e "  ${GREEN}✓${NC} Audio ready"

# ============== DISPLAY ==============
echo -e "  ${YELLOW}⏳${NC} Starting X11 display server..."
termux-x11 :0 -ac &
sleep 2
export DISPLAY=:0
echo -e "  ${GREEN}✓${NC} Display ready"

# ============== LAUNCH DWM IN ARCH ==============
echo ""
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Open the Termux-X11 app to see the desktop"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

proot-distro login archlinux --shared-tmp -- \
    env DISPLAY=:0 PULSE_SERVER=127.0.0.1 \
    sh -l -c "exec ~/.xinitrc"
