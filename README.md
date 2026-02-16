# termux-dotfiles

Minimal tiling desktop for Android using Termux. Runs **dwm + st + dmenu +
dwmblocks** inside an Arch Linux proot environment, with GPU acceleration
and audio bridged from the Termux host. No root required.

**Theme:** Catppuccin Mocha (Lavender accent)

## Architecture

```
┌──────────────────────────────────────────────────┐
│  Termux (native host)                            │
│                                                  │
│  zsh          ── shell (zinit + starship)         │
│  termux-x11   ── X11 display server              │
│  pulseaudio   ── audio (TCP bridge to Android)   │
│  Mesa Zink    ── OpenGL → Vulkan translation     │
│  Turnip       ── Adreno GPU driver               │
│  proot-distro ── container manager               │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │  Arch Linux (proot guest)                  │  │
│  │                                            │  │
│  │  dwm        ── tiling window manager       │  │
│  │  st         ── terminal emulator           │  │
│  │  dmenu      ── application launcher        │  │
│  │  dwmblocks  ── status bar                  │  │
│  │  picom      ── compositor                  │  │
│  │  dunst      ── notifications               │  │
│  │  neovim     ── editor (lazy.nvim plugins)  │  │
│  │  opencode   ── AI coding assistant (TUI)   │  │
│  │  firefox    ── browser                     │  │
│  │  ranger     ── file manager                │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  Termux-X11 Android app (display viewer)         │
└──────────────────────────────────────────────────┘
```

Display: `App → dwm → Termux-X11 (:0) → Termux-X11 Android app`
GPU: `App (OpenGL) → Mesa Zink (Vulkan) → Turnip (Adreno) → Android GPU`
Audio: `App → PULSE_SERVER=127.0.0.1 → PulseAudio (Termux) → Android`

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Android     | 7.0 or higher |
| Termux      | Install from [GitHub releases](https://github.com/termux/termux-app/releases) (not Play Store) |
| Termux-X11  | Install from [GitHub releases](https://github.com/termux/termux-x11/releases) |
| Storage     | ~3 GB free space |
| Internet    | Required for installation |

> **Important:** The Play Store version of Termux is outdated and will not
> work. Always install from GitHub or F-Droid.

## Installation

Open Termux and run:

```bash
git clone https://github.com/YannickHerrero/termux-dotfiles.git
cd termux-dotfiles
bash install.sh
```

### Migrating from termux-hacklab

If you previously installed
[termux-hacklab](https://github.com/jarvesusaram99/termux-hacklab), run
the cleanup script first to remove its artifacts (XFCE4, security tools,
Wine, desktop shortcuts, etc.):

```bash
bash cleanup.sh
```

This removes hacklab-only packages and files while **keeping** shared
dependencies (x11-repo, termux-x11, pulseaudio, mesa drivers, git, wget,
curl). Safe to run multiple times.

The installer will:
1. Update Termux packages
2. Set up Zsh with Starship prompt, zinit plugins, and CLI tools
3. Install X11, GPU drivers, and PulseAudio
4. Install proot-distro and set up Arch Linux
5. Install Neovim, opencode, and dependencies inside Arch
6. Build dwm, st, dmenu, and dwmblocks from source inside Arch
7. Bootstrap Neovim plugins (lazy.nvim auto-sync)
8. Symlink all dotfiles into the Arch home directory

Installation takes approximately 15-30 minutes depending on your internet
connection.

## Usage

### Start the desktop

1. Open the **Termux-X11** Android app first
2. In Termux, run:

```bash
bash ~/start-desktop.sh
```

### Stop the desktop

```bash
bash ~/stop-desktop.sh
```

### Neovim

Open a terminal (st) and run:

```bash
nvim
```

Plugins are pre-installed during setup. If you need to update them:

```
:Lazy sync
```

### opencode

opencode is a terminal-based AI coding assistant. Run it in any project
directory:

```bash
opencode
```

Set your API key first (e.g., for Anthropic):

```bash
export ANTHROPIC_API_KEY="your-key-here"
```

Add it to your `~/.zshrc` to persist across sessions.

### Termux Shell

The Termux host shell is **Zsh** with:

- **Starship** prompt -- zen style (Catppuccin Mocha colors)
- **Zinit** plugin manager -- syntax highlighting, autosuggestions,
  completions
- **zoxide** -- smart `cd` replacement (use `z` to jump to directories)
- **eza** -- modern `ls` with colors and icons
- **bat** -- syntax-highlighted `cat`

#### Shell Aliases

| Alias | Command |
|-------|---------|
| `v` | `nvim` |
| `oc` | `opencode` |
| `ls` | `eza --color=always --icons=auto` |
| `ll` | `eza -la --color=always --icons=auto` |
| `lt` | `eza --tree --level=2` |
| `cat` | `bat --plain` |
| `z <dir>` | `zoxide` smart cd |
| `..` / `...` / `....` | Navigate up directories |
| `mkcd <dir>` | Create directory and cd into it |

#### Shell Functions

| Function | Description |
|----------|-------------|
| `git-personal` / `gsp` | Set git user to personal account for current repo |

## Keybindings

`Alt` is the modifier key (referred to as `Mod` below).

### Essentials

| Keybinding | Action |
|------------|--------|
| `Mod + Shift + Enter` | Open terminal (st) |
| `Mod + p` | Open application launcher (dmenu) |
| `Mod + w` | Open Firefox |
| `Mod + Shift + c` | Close focused window |
| `Mod + Shift + q` | Quit dwm |

### Navigation

| Keybinding | Action |
|------------|--------|
| `Mod + j` | Focus next window |
| `Mod + k` | Focus previous window |
| `Mod + Enter` | Promote focused window to master |
| `Mod + Tab` | Toggle between current and previous tag |
| `Mod + 1-5` | Switch to tag 1-5 |
| `Mod + Shift + 1-5` | Move focused window to tag 1-5 |
| `Mod + 0` | View all tags |

### Layout

| Keybinding | Action |
|------------|--------|
| `Mod + t` | Tiled layout (default) |
| `Mod + m` | Monocle layout (fullscreen, one window) |
| `Mod + f` | Floating layout |
| `Mod + Space` | Toggle between current and previous layout |
| `Mod + Shift + Space` | Toggle focused window floating |
| `Mod + h` | Shrink master area |
| `Mod + l` | Expand master area |
| `Mod + i` | Add window to master area |
| `Mod + d` | Remove window from master area |

### Mouse

| Action | Effect |
|--------|--------|
| `Mod + Left click` | Move window (floating) |
| `Mod + Right click` | Resize window (floating) |
| `Mod + Middle click` | Toggle floating |
| Click on tag number | Switch to that tag |
| Click on layout symbol | Toggle layout |

### Neovim (Space as leader)

| Keybinding | Action |
|------------|--------|
| `Space + Space` | Find files (telescope) |
| `Space + sg` | Live grep (telescope) |
| `Space + fb` | List buffers |
| `Space + fh` | Help tags |
| `Space + fr` | Recent files |
| `Space + sd` | Diagnostics |
| `Space + e` | Toggle file explorer (neo-tree) |
| `Space + ?` | Show buffer keymaps (which-key) |
| `Space + bd` | Delete buffer |
| `Space + bp` | Pin buffer (bufferline) |
| `Space + bo` | Close other buffers |
| `Shift + h` | Previous buffer |
| `Shift + l` | Next buffer |
| `Ctrl + h/j/k/l` | Navigate between windows |
| `jk` | Exit insert mode |

## File Structure

```
termux-dotfiles/
├── install.sh              Termux host setup (run once)
├── cleanup.sh              Remove previous hacklab artifacts
├── start-desktop.sh        Start X11 + audio + dwm session
├── stop-desktop.sh         Kill desktop session
├── config/
│   └── gpu.sh              GPU environment variables
├── termux/
│   ├── setup-shell.sh      Shell installer (zsh, starship, tools)
│   ├── .zshrc              Zsh config (zinit + module loader)
│   ├── zsh/
│   │   ├── aliases.zsh     Shell aliases
│   │   ├── completions.zsh Completion settings
│   │   ├── functions.zsh   Shell functions (git-personal)
│   │   ├── history.zsh     History config
│   │   └── tools.zsh       starship + zoxide init
│   └── starship/
│       └── starship.toml   Prompt config (Catppuccin Mocha)
└── arch/
    ├── setup.sh            Arch guest setup (pacman, suckless builds)
    ├── home/
    │   ├── .xinitrc         Session startup script
    │   └── .config/
    │       ├── nvim/        Neovim config (lazy.nvim + plugins)
    │       ├── picom/       Compositor config
    │       ├── dunst/       Notification daemon config
    │       └── ranger/      File manager config
    └── suckless/
        ├── dwm/             Window manager
        │   ├── config.h     Full configuration
        │   └── patches/     .diff patches (applied in order)
        ├── st/              Terminal emulator
        │   ├── config.h     Reference (applied via sed)
        │   └── patches/
        ├── dmenu/           Application launcher
        │   ├── config.h     Full configuration
        │   └── patches/
        └── dwmblocks/       Status bar
            ├── config.h     Block definitions
            ├── patches/
            └── scripts/     sb-battery, sb-wifi, sb-volume, sb-datetime
```

## Customization

### Changing colors

All tools use the **Catppuccin Mocha** color scheme with **Lavender**
(`#b4befe`) as the accent color. To change the theme, update these files:

- `arch/suckless/dwm/config.h` -- bar and border colors
- `arch/suckless/dmenu/config.h` -- launcher colors
- `arch/setup.sh` -- st terminal colors (sed block in `build_st()`)
- `arch/home/.config/dunst/dunstrc` -- notification colors
- `arch/home/.config/nvim/lua/plugins/catppuccin.lua` -- Neovim theme flavour
- `arch/home/.xinitrc` -- root window background
- `termux/starship/starship.toml` -- Termux prompt colors

### Modifying suckless tools

Suckless tools are configured by editing C header files and recompiling.

1. Edit the `config.h` in the relevant `arch/suckless/<tool>/` directory
2. Rebuild inside the Arch proot:

```bash
proot-distro login archlinux
cd /tmp && git clone https://git.suckless.org/dwm && cd dwm
# Apply any patches first
for p in /root/.dotfiles/suckless/dwm/patches/*.diff; do
    git apply "$p" 2>/dev/null || patch -p1 < "$p"
done
cp /root/.dotfiles/suckless/dwm/config.h .
make clean install
```

For **st** specifically, the config is applied via sed (see `arch/setup.sh`,
the `build_st()` function). Edit the sed commands there rather than a
config.h file.

### Adding patches

1. Download the `.diff` file from [suckless.org/patches](https://suckless.org/patches/)
2. Place it in the appropriate `patches/` directory (e.g., `arch/suckless/dwm/patches/`)
3. Patches are applied in filename order, so prefix with numbers if order matters
   (e.g., `01-gaps.diff`, `02-status2d.diff`)
4. Rebuild the tool (see above)

### Adding status bar blocks

1. Create a new script in `arch/suckless/dwmblocks/scripts/` named `sb-<name>`
2. Make it executable: `chmod +x sb-<name>`
3. Add an entry in `arch/suckless/dwmblocks/config.h`:
   ```c
   { "sb-name", update_interval_seconds, signal_number },
   ```
4. Rebuild dwmblocks

## Troubleshooting

### Black screen / nothing happens

- Make sure the **Termux-X11 Android app** is open before running
  `start-desktop.sh`
- Check that the X11 server is running: `pgrep -f termux.x11`

### GPU acceleration not working

- Run `glxinfo | grep renderer` inside the Arch proot to check which
  renderer is active
- If it shows `llvmpipe`, the GPU drivers aren't working; check that
  `mesa-zink` and `mesa-vulkan-icd-freedreno` (or `swrast`) are installed
  on the Termux host
- Verify `~/.config/gpu.sh` is sourced in your environment

### No audio

- Check PulseAudio is running on the Termux host: `pulseaudio --check`
- Inside Arch, verify `PULSE_SERVER` is set: `echo $PULSE_SERVER`
  (should be `127.0.0.1`)
- Ensure `pulseaudio` is installed in the Arch guest for the `pactl` tool

### dwm crashes or won't start

- Check `.xinitrc` has execute permission: `chmod +x ~/.xinitrc`
- Look for errors: `proot-distro login archlinux -- sh -c "DISPLAY=:0 dwm"` 
  to see error output directly
- Verify dwm was compiled: `which dwm` inside the Arch proot

### Phantom process killer (Samsung / Android 12+)

Android may kill background Termux processes. To prevent this:
1. Open **Developer Options** on your phone
2. Search for **Phantom Process Killer** and disable it
3. Alternatively, run: `adb shell settings put global settings_enable_monitor_phantom_procs false`

## Tips

- **Monocle layout** (`Mod + m`) is ideal when using the phone without an
  external keyboard -- it gives each app full screen
- **Bluetooth keyboard/mouse** significantly improve the dwm experience
- The dwmblocks status bar shows: network | battery | volume | date/time
- Use `Mod + Shift + 1-5` to organize windows across tags before switching
  between them with `Mod + 1-5`
- In Neovim, press `Space` and wait -- **which-key** will show all available
  keybindings after a short delay
- Run `:checkhealth` in Neovim to verify all plugins and dependencies are
  working correctly
- **opencode** works best with a project directory -- `cd` into your project
  before launching it

## License

Personal dotfiles -- use and modify freely.
