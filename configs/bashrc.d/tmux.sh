# --- tmux auto-launch ---

# Guard: skip if tmux is not installed
command -v tmux &>/dev/null || return

# Attach to (or create) the default tmux session on interactive shell startup
if [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
	tmux a -t default || exec tmux new -s default && exit
fi
