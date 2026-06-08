# --- Neovim aliases and settings ---

# Guard: skip if nvim is not installed
command -v nvim &>/dev/null || return

export EDITOR=nvim
export MANPAGER='nvim +Man!'

alias v='nvim'
