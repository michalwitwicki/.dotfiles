# --- Prompt ---

git_parse_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\[$(tput setaf 9)\][\[$(tput setaf 10)\]\t \[$(tput setaf 11)\]\W\[$(tput setaf 9)\]]\[$(tput setaf 13)\]\$(git_parse_branch)\[$(tput setaf 15)\]\\$ \[$(tput sgr0)\]"
