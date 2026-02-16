# Set git to use personal account in current repository
git-personal() {
	local git_root
	git_root=$(git rev-parse --show-toplevel 2>/dev/null)

	if [[ -z "$git_root" ]]; then
		echo "Error: Not in a git repository"
		return 1
	fi

	git config --local user.name "YannickHerrero"
	git config --local user.email "yannick.herrero@proton.me"

	echo "Git personal account configured for: $(basename "$git_root")"
	echo "  Name:  YannickHerrero"
	echo "  Email: yannick.herrero@proton.me"
}
alias gsp='git-personal'

# Project picker - select a project from ~/dev and cd into it
f() {
	local dir
	dir=$(find "$HOME/dev" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | \
	fzf --preview "eza --tree --level=1 --color=always $HOME/dev/{}" \
		--bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')

	if [[ -z "$dir" ]]; then
		return
	fi

	cd "$HOME/dev/$dir" || return
}

# Fuzzy file finder - open selected file in nvim
ff() {
	local file
	file=$(find "$HOME/dev" "$HOME/.config" -type d \( \
		-path "*/node_modules" -o \
		-path "*/.git" -o \
		-path "*/.cache" -o \
		-path "*/.vscode" -o \
		-path "*/.npm" -o \
		-path "*/dist" -o \
		-path "*/.next" -o \
		-path "*/.expo" -o \
		-path "*/db" -o \
		-path "*/build" -o \
		-path "*/__pycache__" -o \
		-path "*/.idea" -o \
		-path "*/.env" -o \
		-path "*/.vs" -o \
		-path "*/vendor" -o \
		-path "*/coverage" -o \
		-path "*/.terraform" -o \
		-path "*/.bundle" -o \
		-path "*/tmp" -o \
		-path "*/logs" -o \
		-path "*/.sass-cache" \
	\) -prune -o -type f -print 2>/dev/null | \
	fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
		--bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
	if [[ -n "$file" ]]; then
		nvim "$file"
	fi
}
