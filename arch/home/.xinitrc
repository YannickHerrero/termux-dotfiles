#!/bin/sh
# ============== .xinitrc ==============
# Session startup for dwm desktop in Arch proot.
# Launched by start-desktop.sh via proot-distro login.

# Compositor (transparency, shadows, fade)
picom --daemon 2>/dev/null &

# Notification daemon
dunst &

# Status bar
dwmblocks &

# Set wallpaper to solid color (or use feh for an image)
xsetroot -solid "#1e1e2e"

# Uncomment to use a wallpaper image:
# feh --bg-fill ~/.config/wallpaper.jpg &

# Start dwm (exec replaces the shell process)
exec dwm
