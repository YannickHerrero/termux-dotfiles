export PATH="$HOME/.local/bin:$PATH"

# GPU environment (Mesa Zink / Turnip)
source ~/.config/gpu.sh 2>/dev/null

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

autoload -Uz compinit && compinit
zinit cdreplay -q

# Source configs
for config in ~/.zsh/*.zsh; do
    source "$config"
done
