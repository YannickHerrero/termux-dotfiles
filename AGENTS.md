# AGENTS.md - Coding Agent Guidelines for termux-dotfiles

## Project Overview

Personal dotfiles repository for a Termux setup on Android. Provides a
minimal tiling desktop (dwm + st + dmenu + dwmblocks) running Arch Linux
inside proot-distro, with GPU acceleration and audio bridged from the
Termux host. No root required.

**Architecture:** Hybrid -- Termux native (display, GPU, audio) + Arch
Linux proot guest (window manager, applications, dotfiles).

The `reference/` folder is a local-only collection of third-party suckless
builds (gitignored). It contains reference implementations of dwm, st, and
other tools used as inspiration for patches and configuration. **Do not
modify or commit anything inside `reference/`.**

**Languages:** Bash (shell scripts), C (suckless `config.h` files), Lua (Neovim config)
**Target runtime:** Termux on Android (ARM64)
**Shebang:** `#!/data/data/com.termux/files/usr/bin/bash` (Termux host scripts)
**Package managers:** `pkg` (Termux host), `pacman` (Arch guest)

## Repository Structure

```
termux-dotfiles/
  AGENTS.md                              # This file
  .gitignore                             # Ignores reference/
  install.sh                             # Termux host one-time setup
  start-desktop.sh                       # Launch X11 + audio + dwm session
  stop-desktop.sh                        # Kill desktop session
  config/
    gpu.sh                               # GPU env vars (Mesa Zink/Turnip)
  arch/
    setup.sh                             # Runs inside Arch proot: pacman + build suckless
    home/
      .xinitrc                           # Session startup (wal-restore, picom, dunst, dwmblocks, dwm)
      .zshrc                             # Shell config (zinit, pywal sequences, modules)
      .config/nvim/                        # Neovim config (lazy.nvim, Lua)
      .config/picom/picom.conf           # Compositor
      .config/dunst/dunstrc              # Notifications
      .config/ranger/rc.conf             # File manager
      .config/wal/templates/             # Pywal16 user templates (dwm Xresources)
      .local/bin/set-wallpaper           # Wallpaper selector (nsxiv + pywal16 + feh)
      .local/bin/wal-restore             # Restore pywal theme on session start
    suckless/
      dwm/config.h                       # dwm configuration (full config.h)
      dwm/patches/                       # dwm patches (.diff files)
      st/config.h                        # st customization reference (applied via sed)
      st/patches/                        # st patches
      dmenu/config.h                     # dmenu configuration (full config.h)
      dmenu/patches/                     # dmenu patches
      dwmblocks/config.h                 # Status bar block definitions
      dwmblocks/patches/                 # dwmblocks patches
      dwmblocks/scripts/sb-*             # Status bar scripts (battery, wifi, etc.)
  reference/                             # LOCAL ONLY (gitignored)
    dwm/                                 # BreadOnPenguins' dwm build (patches, config)
    st/                                  # BreadOnPenguins' st build (patches, config)
```

## Build / Lint / Test Commands

No CI pipeline. The project consists of shell scripts and C config headers.

### Full install (on Termux)

```bash
bash install.sh                          # One-time: GPU, X11, audio, proot Arch, suckless builds
```

### Rebuild a single suckless tool (inside Arch proot)

```bash
proot-distro login archlinux
cd /tmp && git clone https://git.suckless.org/dwm && cd dwm
cp /root/.dotfiles/suckless/dwm/config.h .
make clean install
```

For `st`, patch first, then rely on `arch/setup.sh` sed customizations
(`font`, `borderpx`, `tabspaces`, `bellvolume`, `alpha`, Catppuccin colors)
instead of maintaining a full `config.h`.

### Linting

```bash
shellcheck install.sh                    # Lint a single script
shellcheck -s bash -x <script>.sh        # With source following
shellcheck arch/suckless/dwmblocks/scripts/*  # Lint status bar scripts
```

### Testing

No test suite. Manual testing requires Termux on Android.
Consider `bats-core` for Bash tests and `shellcheck` as a quality gate.

## Code Style Guidelines

### Script File Layout (Bash)

1. Shebang (`#!/data/data/com.termux/files/usr/bin/bash` for host, `#!/bin/bash` for Arch)
2. `set -euo pipefail`
3. Header comment block (name, description, purpose)
4. Configuration constants
5. Color/formatting variables
6. Utility functions
7. Step/task functions
8. `main()` orchestrator
9. Bare `main` call at the bottom

Use section banners: `# ============== SECTION NAME ==============`

### Suckless config.h Files (C)

- dwm, dmenu, dwmblocks: ship a **complete `config.h`** that replaces `config.def.h`
- st: customizations applied via **sed on `config.def.h`** at build time
  (avoids maintaining 300+ lines of key mapping boilerplate)
- Patches go in `<tool>/patches/` as `.diff` files, applied in filename order
- Color scheme: **Catppuccin Mocha** as default, dynamically overridden by
  **pywal16** when a wallpaper is selected (`#1e1e2e` bg, `#cdd6f4` fg,
  `#b4befe` Lavender accent are the compiled-in fallback defaults)

### Current Patch Sets (reference)

- `dwm` (base: `6.5`):
  `01-push-updown`, `02-vanitygaps`, `03-swallow`, `04-hide-vacant-tags`,
  `05-restartsig`, `06-colorbar`, `07-statuscmd`, `08-xrdb`
- `st` (base: `0.9.2`):
  `01-ligatures-alpha-scrollback-ringbuffer`,
  `02-scrollback-mouse-changealpha-anysize`
- `dwmblocks`:
  `01-fix-termhandler-signature`, `02-statuscmd`

### Patch Compatibility Rules

- Always verify the **full chain** applies on a clean upstream checkout,
  not just individual patches in isolation
- If patch context breaks due to earlier patches, fix the `.diff` hunk context
  and line counts (do not reorder unless intentionally redesigning the chain)
- Keep numbering stable unless a deliberate migration is documented

### Naming Conventions

| Element            | Convention         | Examples                              |
|--------------------|--------------------|---------------------------------------|
| Functions          | `snake_case`       | `update_progress`, `install_pkg`      |
| Step functions     | `step_<name>`      | `step_update`, `step_gpu`             |
| Global variables   | `UPPER_SNAKE_CASE` | `TOTAL_STEPS`, `GPU_DRIVER`           |
| Local variables    | `snake_case`       | `local pid=$1`, `local name=$2`       |
| Color constants    | `UPPER_SNAKE_CASE` | `RED`, `GREEN`, `NC`, `BOLD`          |
| Status bar scripts | `sb-<name>`        | `sb-battery`, `sb-wifi`, `sb-volume`  |

### Quoting and Expansion

- Double-quote variables: `"$variable"`
- Use `[[ ]]` for conditionals (bash), `[ ]` only in `/bin/sh` scripts
- Pattern matching: `[[ "$var" == *"pattern"* ]]`
- Arithmetic: `$(( ))` or `$((expression))`

### Error Handling

- `set -euo pipefail` at the top of every script
- `2>/dev/null` for commands that may fail benignly
- `|| fallback` for defaults: `command 2>/dev/null || echo "fallback"`
- `|| true` after `pkill`/`kill` to avoid set -e failures
- Background process exit codes via `wait $pid` + `$?`

### Output Conventions

- ANSI color codes via variables (`$RED`, `$GREEN`, `$NC`, etc.)
- Status indicators: `✓` success, `✗` failure, `⏳` in-progress
- Spinner animation (Braille characters: `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`)
- Progress bar with `█` (filled) and `░` (empty)

### Background Process Pattern

```bash
(yes | pkg install "$pkg" -y > /dev/null 2>&1) &
spinner $! "Installing ${name}..."
```

## Architecture Notes

### Two-layer system

| Layer        | Runs on        | Managed by     | Purpose                       |
|--------------|----------------|----------------|-------------------------------|
| Termux host  | Android native | `pkg`          | X11 server, GPU, audio, proot |
| Arch guest   | proot-distro   | `pacman`       | dwm, st, dmenu, apps, dotfiles|

### Display pipeline

```
App (OpenGL) -> Mesa Zink (-> Vulkan) -> Turnip (Adreno) -> Android GPU
dwm -> Termux-X11 (:0) -> Termux-X11 Android app
```

### Audio pipeline

```
App (Arch) -> PULSE_SERVER=127.0.0.1 -> PulseAudio (Termux host) -> Android audio
```

### Desktop session launch

`start-desktop.sh` (Termux) -> PulseAudio + Termux-X11 -> `proot-distro login`
-> `.xinitrc` (Arch) -> wal-restore + picom + dunst + dwmblocks + `exec dwm`

## Theming / Wallpaper System

The desktop supports dynamic color scheme changes via **pywal16**. The
`set-wallpaper` script (Alt+w) opens nsxiv to pick an image, generates
a 16-color palette, and live-reloads colors across all components:

### Color reload pipeline

```
set-wallpaper (Alt+w)
  -> nsxiv (pick from ~/wallpapers)
  -> wal -i <image> (generate palette + OSC sequences)
  -> feh --bg-fill (set wallpaper)
  -> xrdb -merge (load colors into X server)
  -> xdotool key alt+F5 (signal dwm to reload via xrdb)
  -> cat sequences > /dev/pts/* (update running terminals)
  -> pkill/restart dunst (with new colors)
  -> pkill -RTMIN dwmblocks (refresh status bar)
```

### How each tool picks up colors

| Tool      | Method                         | Live reload? |
|-----------|--------------------------------|--------------|
| dwm       | xrdb patch reads X resources   | Yes (Alt+F5) |
| st        | pywal OSC escape sequences     | Yes (instant)|
| dmenu     | Colors from dwm config vars    | Next launch  |
| dunst     | Restarted with CLI color args  | Yes          |
| dwmblocks | Scripts can source colors.sh   | Yes (signal) |

### Pywal user templates

Custom templates live in `arch/home/.config/wal/templates/`. Pywal
generates output files in `~/.cache/wal/` using these templates:

- `colors-dwm.Xresources` -- maps pywal colors to dwm X resource names

### Session persistence

On startup, `.xinitrc` calls `wal-restore` which:
1. Merges cached Xresources (so dwm starts with last theme)
2. Restores the wallpaper via feh
3. Falls back to Catppuccin Mocha if no theme was ever set

New terminal windows source `~/.cache/wal/sequences` from `.zshrc`.

## Reference Material

The `reference/` directory (gitignored) contains third-party suckless tool
builds kept locally for patch and configuration inspiration:

- `reference/dwm/` -- BreadOnPenguins' dwm build (vanitygaps, swallow,
  stacker, xrdb, colorbar, and other patches)
- `reference/st/` -- BreadOnPenguins' st build (alpha, ligatures,
  scrollback, xresources, anysize patches)

## Adding New Scripts

1. Use the correct shebang for the target layer
2. Add `set -euo pipefail` immediately after the shebang
3. Include a header comment block with description
4. Use section banners for organization
5. Follow `step_<name>` for installer steps, `sb-<name>` for status scripts
6. Provide user feedback with colored output and status indicators
7. Quote all variables, especially in commands that take user input
8. Run `shellcheck` before committing
