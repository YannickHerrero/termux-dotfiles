/* dmenu config.h - Termux mobile suckless launcher
 *
 * Gruvbox color scheme, matches dwm and st.
 * Bottom bar positioning works well on phone screens
 * since the keyboard appears at the bottom.
 */

/* -b  option; if 0, dmenu appears at bottom */
static int topbar = 1;

/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"DejaVu Sans Mono:size=11"
};

static const char *prompt = NULL; /* -p option; prompt to the left of input field */

/* gruvbox colors */
static const char *colors[SchemeLast][2] = {
	/*                  fg         bg       */
	[SchemeNorm]    = { "#ebdbb2", "#282828" },
	[SchemeSel]     = { "#282828", "#d65d0e" },
	[SchemeOut]     = { "#000000", "#00ffff" },
};

/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
