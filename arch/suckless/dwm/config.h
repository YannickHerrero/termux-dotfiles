/* dwm config.h - Termux mobile suckless desktop
 *
 * Optimized for phone screens and touch/keyboard use.
 * Spiral layout by default (fibonacci with gaps).
 *
 * Patches applied:
 *   01-push-updown    -- Reorder windows in the stack
 *   02-vanitygaps     -- Configurable inner/outer gaps + spiral/dwindle layouts
 *   03-swallow        -- Terminal swallows GUI child processes
 *   04-hide-vacant    -- Only show tags with clients on the bar
 *   05-restartsig     -- Restart dwm in-place via keybind or signal
 *   06-colorbar       -- Per-element bar color schemes
 *   07-statuscmd      -- Clickable status bar blocks (dwmblocks integration)
 *   08-xrdb           -- Runtime color reload from X resources (pywal integration)
 *
 * Keybindings (Alt = MODKEY):
 *   Alt+hjkl            focus windows
 *   Alt+Shift+hjkl      move/resize windows
 *   Alt+Space            launcher (dmenu)
 *   Alt+Enter            terminal (st)
 *   Alt+b                browser (firefox)
 *   Alt+w                wallpaper selector (set-wallpaper)
 *   Alt+F5               reload colors from xrdb
 *   Alt+f                toggle fullscreen (monocle)
 *   Alt+t                toggle floating
 *   Alt+Shift+t          tiled layout
 *   Alt+s                spiral layout (default)
 *   Alt+Shift+s          dwindle layout
 *   Alt+minus/equal      decrease/increase gaps
 *   Alt+Shift+minus      reset gaps
 *   Alt+Shift+equal      toggle gaps
 *   Alt+1-9              switch workspace
 *   Alt+Shift+1-9        move window to workspace and follow
 *   Alt+q                close window
 *   Alt+Shift+q          quit dwm
 *   Alt+Ctrl+Shift+q     restart dwm
 */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 16;       /* snap pixel */

/* vanitygaps: gap settings (smaller for mobile screens) */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 15;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */

/* swallow: terminal swallowing */
static const int swallowfloating    = 0;        /* 1 means swallow floating windows by default */

static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "DejaVu Sans Mono:size=11" };
static const char dmenufont[]       = "DejaVu Sans Mono:size=11";

/* ============== CATPPUCCIN MOCHA COLOR SCHEME ============== */
/* Mutable color variables — overwritten at runtime by xrdb (Mod+F5).
 * Catppuccin Mocha values serve as compile-time defaults. */
static char col_normfg[]      = "#cdd6f4"; /* Text */
static char col_normbg[]      = "#1e1e2e"; /* Base */
static char col_normborder[]  = "#313244"; /* Surface0 */
static char col_selfg[]       = "#1e1e2e"; /* Base */
static char col_selbg[]       = "#b4befe"; /* Lavender (accent) */
static char col_selborder[]   = "#b4befe"; /* Lavender (accent) */
static char col_statusfg[]    = "#bac2de"; /* Subtext1 */
static char col_statusbg[]    = "#181825"; /* Mantle */
static char col_tagsselfg[]   = "#1e1e2e"; /* Base */
static char col_tagsselbg[]   = "#b4befe"; /* Lavender */
static char col_tagsnormfg[]  = "#6c7086"; /* Overlay0 */
static char col_tagsnormbg[]  = "#1e1e2e"; /* Base */
static char col_infoselfg[]   = "#cdd6f4"; /* Text */
static char col_infoselbg[]   = "#313244"; /* Surface0 */
static char col_infonormfg[]  = "#a6adc8"; /* Subtext0 */
static char col_infonormbg[]  = "#1e1e2e"; /* Base */

/* colorbar: 7 color schemes for bar elements */
static char *colors[][3]      = {
	/*                    fg              bg              border   */
	[SchemeNorm]      = { col_normfg,     col_normbg,     col_normborder },
	[SchemeSel]       = { col_selfg,      col_selbg,      col_selborder  },
	[SchemeStatus]    = { col_statusfg,   col_statusbg,   col_normbg     }, /* statusbar right */
	[SchemeTagsSel]   = { col_tagsselfg,  col_tagsselbg,  col_normbg     }, /* tagbar selected */
	[SchemeTagsNorm]  = { col_tagsnormfg, col_tagsnormbg, col_normbg     }, /* tagbar unselected */
	[SchemeInfoSel]   = { col_infoselfg,  col_infoselbg,  col_normbg     }, /* infobar selected */
	[SchemeInfoNorm]  = { col_infonormfg, col_infonormbg, col_normbg     }, /* infobar unselected */
};

/* tagging -- 9 workspaces */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* swallow: rules with isterminal and noswallow fields */
static const Rule rules[] = {
	/* class      instance    title       tags mask  isfloating  isterminal  noswallow  monitor */
	{ "St",       NULL,       NULL,       0,         0,          1,          0,         -1 },
	{ "Firefox",  NULL,       NULL,       1 << 1,    0,          0,          0,         -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

/* vanitygaps: include layout functions (must come after mfact/nmaster) */
#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
	/* symbol   arrange function */
	{ "[@]",    spiral },    /* default: fibonacci spiral with gaps */
	{ "[]=",    tile },      /* tiled: master left, stack right */
	{ "[M]",    monocle },   /* fullscreen: one window at a time */
	{ "[\\]",   dwindle },   /* fibonacci dwindle variant */
	{ "><>",    NULL },      /* floating: no layout, free placement */
};

/* key definitions */
#define MODKEY Mod1Mask  /* Alt key (Mod4/Super may not work on phone) */

/* statuscmd: dwmblocks status bar name */
#define STATUSBAR "dwmblocks"

/* Alt+Shift+N: move window to tag N and follow focus there */
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tagandview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[]  = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont,
	"-nb", col_normbg, "-nf", col_normfg, "-sb", col_selbg, "-sf", col_selfg, NULL };
static const char *termcmd[]   = { "st", NULL };
static const char *browsercmd[] = { "firefox", NULL };

/* custom function: tag window and follow focus */
static void tagandview(const Arg *arg) {
	if (arg->ui & TAGMASK) {
		tag(arg);
		view(arg);
	}
}

static const Key keys[] = {
	/* modifier                     key        function        argument */

	/* launchers */
	{ MODKEY,                       XK_space,  spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      spawn,          {.v = browsercmd } },
	{ MODKEY,                       XK_w,      spawn,          SHCMD("set-wallpaper") },

	/* reload colors from xrdb */
	{ MODKEY,                       XK_F5,     xrdb,           {.v = NULL } },

	/* focus windows: Alt + hjkl */
	{ MODKEY,                       XK_h,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_l,      focusstack,     {.i = +1 } },

	/* move/resize windows: Alt + Shift + hjkl */
	{ MODKEY|ShiftMask,             XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY|ShiftMask,             XK_j,      pushdown,       {0} },
	{ MODKEY|ShiftMask,             XK_k,      pushup,         {0} },
	{ MODKEY|ShiftMask,             XK_l,      setmfact,       {.f = +0.05} },

	/* promote focused window to master */
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },

	/* layout switching */
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[0]} }, /* spiral (default) */
	{ MODKEY|ShiftMask,             XK_t,      setlayout,      {.v = &layouts[1]} }, /* tile */
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[2]} }, /* monocle/fullscreen */
	{ MODKEY|ShiftMask,             XK_s,      setlayout,      {.v = &layouts[3]} }, /* dwindle */

	/* toggle floating for focused window */
	{ MODKEY,                       XK_t,      togglefloating, {0} },

	/* vanitygaps: gap controls */
	{ MODKEY,                       XK_minus,  incrgaps,       {.i = -3 } },
	{ MODKEY,                       XK_equal,  incrgaps,       {.i = +3 } },
	{ MODKEY|ShiftMask,             XK_minus,  defaultgaps,    {0} },   /* reset gaps */
	{ MODKEY|ShiftMask,             XK_equal,  togglegaps,     {0} },   /* toggle gaps */

	/* close window */
	{ MODKEY,                       XK_q,      killclient,     {0} },

	/* toggle bar */
	{ MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },

	/* view all tags */
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },

	/* switch between last two workspaces */
	{ MODKEY,                       XK_Tab,    view,           {0} },

	/* master area count */
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },

	/* workspaces 1-9 */
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)

	/* quit / restart dwm (restartsig) */
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },   /* quit */
	{ MODKEY|ControlMask|ShiftMask, XK_q,      quit,           {1} },   /* restart */
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[4]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	/* statuscmd: clickable status bar blocks */
	{ ClkStatusText,        0,              Button1,        sigstatusbar,   {.i = 1} },
	{ ClkStatusText,        0,              Button2,        sigstatusbar,   {.i = 2} },
	{ ClkStatusText,        0,              Button3,        sigstatusbar,   {.i = 3} },
	{ ClkStatusText,        0,              Button4,        sigstatusbar,   {.i = 4} },
	{ ClkStatusText,        0,              Button5,        sigstatusbar,   {.i = 5} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
