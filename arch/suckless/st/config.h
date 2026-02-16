/* st config.h - Termux mobile suckless terminal
 *
 * This is a reference for the customizations applied to st's config.def.h
 * by arch/setup.sh at build time (via sed). We don't ship a full config.h
 * because st's default key tables are ~200 lines of boilerplate that
 * change between versions.
 *
 * Customizations applied:
 *   - Font:       DejaVu Sans Mono, 16px
 *   - Border:     2px
 *   - Tab width:  4 spaces
 *   - Bell:       disabled
 *   - Colors:     Catppuccin Mocha (see below)
 *
 * Catppuccin Mocha palette:
 *   bg      = #1e1e2e (Base)       fg      = #cdd6f4 (Text)
 *   cursor  = #f5e0dc (Rosewater)
 *
 *   [0]  = #45475a  Surface1    (black)
 *   [1]  = #f38ba8  Red         (red)
 *   [2]  = #a6e3a1  Green       (green)
 *   [3]  = #f9e2af  Yellow      (yellow)
 *   [4]  = #89b4fa  Blue        (blue)
 *   [5]  = #f5c2e7  Pink        (magenta)
 *   [6]  = #94e2d5  Teal        (cyan)
 *   [7]  = #bac2de  Subtext1    (white)
 *   [8]  = #585b70  Surface2    (bright black)
 *   [9]  = #f38ba8  Red         (bright red)
 *   [10] = #a6e3a1  Green       (bright green)
 *   [11] = #f9e2af  Yellow      (bright yellow)
 *   [12] = #89b4fa  Blue        (bright blue)
 *   [13] = #f5c2e7  Pink        (bright magenta)
 *   [14] = #94e2d5  Teal        (bright cyan)
 *   [15] = #a6adc8  Subtext0    (bright white)
 */
