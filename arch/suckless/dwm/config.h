/* dwm config.h - Termux mobile suckless desktop
 *
 * Optimized for phone screens and touch/keyboard use.
 * Tiled layout by default (master left, stack right).
 *
 * Keybindings follow omarchy-style layout:
 *   Alt+hjkl       focus windows
 *   Alt+Shift+hjkl move/resize windows
 *   Alt+Space      launcher (dmenu)
 *   Alt+Enter      terminal (st)
 *   Alt+b          browser (firefox)
 *   Alt+f          toggle fullscreen (monocle)
 *   Alt+t          toggle floating
 *   Alt+1-9        switch workspace
 *   Alt+Shift+1-9  move window to workspace and follow
 *   Alt+Shift+c    close window
 *   Alt+Shift+q    quit dwm
 */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 16;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "DejaVu Sans Mono:size=11" };
static const char dmenufont[]       = "DejaVu Sans Mono:size=11";

/* catppuccin mocha color scheme */
static const char col_bg[]          = "#1e1e2e";
static const char col_fg[]          = "#cdd6f4";
static const char col_border[]      = "#313244";
static const char col_sel[]         = "#b4befe";
static const char col_sel_fg[]      = "#1e1e2e";

static const char *colors[][3]      = {
	/*                fg         bg         border   */
	[SchemeNorm]  = { col_fg,    col_bg,    col_border },
	[SchemeSel]   = { col_sel_fg,col_sel,   col_sel    },
};

/* tagging -- 9 workspaces */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* class      instance    title       tags mask  isfloating  monitor */
	{ "Firefox",  NULL,       NULL,       1 << 1,    0,          -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol   arrange function */
	{ "[]=",    tile },     /* default: tiled, master left, stack right */
	{ "[M]",    monocle },  /* fullscreen, one window at a time */
	{ "><>",    NULL },     /* floating: no layout, free placement */
};

/* key definitions */
#define MODKEY Mod1Mask  /* Alt key (Mod4/Super may not work on phone) */

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
	"-nb", col_bg, "-nf", col_fg, "-sb", col_sel, "-sf", col_sel_fg, NULL };
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

	/* toggle fullscreen (monocle layout) */
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },

	/* toggle floating for focused window */
	{ MODKEY,                       XK_t,      togglefloating, {0} },

	/* back to tiled layout */
	{ MODKEY|ShiftMask,             XK_t,      setlayout,      {.v = &layouts[0]} },

	/* close window */
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },

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

	/* quit dwm */
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
