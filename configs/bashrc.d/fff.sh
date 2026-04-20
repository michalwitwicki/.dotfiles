# --- FFF settings ---

# Status background color [0-9]
export FFF_COL2=3

# Cursor color [0-9]
export FFF_COL4=5

# Status foreground color [0-9]
export FFF_COL5=0

# Set custom trash command
export FFF_TRASH_CMD="trash"

# cd into last visited directory on exit
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}
