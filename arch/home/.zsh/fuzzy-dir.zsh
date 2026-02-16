# Fuzzy project selector - cd into a project under ~/dev
f() {
    local dir
    dir=$(find "$HOME/dev" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | \
    fzf --preview "ls --color=always $HOME/dev/{}" \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')

    if [ -z "$dir" ]; then
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
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}' \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
    if [ -n "$file" ]; then
        nvim "$file"
    fi
}
