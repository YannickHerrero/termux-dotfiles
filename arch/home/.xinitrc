#!/bin/sh
# ============== .xinitrc ==============
# Session startup for dwm desktop in Arch proot.
# Launched by start-desktop.sh via proot-distro login.

# Restore pywal color scheme and wallpaper (if set)
# Falls back to Catppuccin Mocha defaults on first boot
wal-restore

# Compositor (transparency, shadows, fade)
picom --daemon 2>/dev/null &

# Notification daemon (uses pywal colors if available)
if [ -f "${HOME}/.cache/wal/colors.sh" ]; then
    . "${HOME}/.cache/wal/colors.sh"
    dunst \
        -config "${HOME}/.config/dunst/dunstrc" \
        -frame_color "${color4:-#b4befe}" \
        -lb "${background:-#1e1e2e}" -lf "${foreground:-#cdd6f4}" -lfr "${color8:-#313244}" \
        -nb "${background:-#1e1e2e}" -nf "${foreground:-#cdd6f4}" -nfr "${color4:-#b4befe}" \
        -cb "${background:-#1e1e2e}" -cf "${color1:-#f38ba8}" -cfr "${color1:-#f38ba8}" &
else
    dunst &
fi

# Status bar
dwmblocks &

# Start dwm (exec replaces the shell process)
exec dwm
