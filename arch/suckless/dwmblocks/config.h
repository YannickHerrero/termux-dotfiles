/* dwmblocks config.h - Status bar block definitions
 *
 * Each block runs a script and displays its output in the dwm bar.
 * Format: { "command", update_interval_seconds, signal_number }
 *
 * Signal 0 means no signal-based update (only interval-based).
 * To force-update a block: kill -$((signal + 34)) $(pidof dwmblocks)
 *
 * Scripts live in arch/suckless/dwmblocks/scripts/ and are symlinked
 * to /usr/local/bin/ by setup.sh.
 */

static const Block blocks[] = {
	/* command              interval  signal */
	{ "sb-wifi",            10,       1 },
	{ "sb-battery",         30,       2 },
	{ "sb-volume",          0,        3 },
	{ "sb-datetime",        30,       0 },
};

/* delimiter between blocks */
static char delim[] = "  ";

/* max length of output from each block */
static unsigned int delimLen = 2;
