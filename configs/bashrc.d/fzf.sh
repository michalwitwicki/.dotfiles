# --- FZF settings ---

export FZF_DEFAULT_COMMAND='fd --type file --hidden'
export FZF_DEFAULT_OPTS=''

# Open file picker, enter opens selection in nvim
fzf_find_file() {
    fzf --preview='bat --color=always {}' \
        --preview-window 'up:60%:border-bottom:~3' \
        --bind 'enter:become(nvim {})'
}

# Live ripgrep search, enter opens match in nvim at the correct line
fzf_find_grep() {
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --hidden"
    INITIAL_QUERY="${*:-}"
    $RG_PREFIX $(printf %q "$INITIAL_QUERY") | \
        fzf --ansi \
        --disabled --query "$INITIAL_QUERY" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up:60%:border-bottom:+{2}+3/3:~3' \
        --bind 'enter:become(nvim {1} +{2})'
}
