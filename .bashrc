#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Launch tmux session on bash startup ---
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  tmux a -t default || exec tmux new -s default && exit;
fi

# --- Settings ---
# user specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# set default editor
export EDITOR=nvim

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# --- FZF settings ---
# export FZF_DEFAULT_COMMAND='fd --type file --hidden --no-ignore'
export FZF_DEFAULT_COMMAND='fd --type file --hidden'
export FZF_DEFAULT_OPTS=''

# --- Various aliases ---
alias v='nvim'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias rs='rsync --exclude=.git --info=progress2 --stats --delete -h -azr'

# warning to use trash-cli instead of rm
alias rm='  echo "This is not the command you are looking for."
            echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
            echo "If you in desperate need of rm use this -> \rm"; false'

# --- GIT related functions and aliases ---
git-parse-branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

git-fzf-branch()
{
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

git-fzf-checkout()
{
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(git-fzf-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}


git-fzf-log ()
{
	PREVIEW_COMMAND='f() {
		set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}")
		[ $# -eq 0 ] || (
			git show --no-patch --color=always $1
			echo
			git show --stat --format="" --color=always $1 |
			while read line; do
				tput dim
				echo " $line" | sed "s/\x1B\[m/\x1B\[2m/g"
				tput sgr0
			done |
			tac | sed "1 a \ " | tac
            echo
            git show $1 --format="" --color=always | delta --side-by-side -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}
		)
	}; f {}'

	ENTER_COMMAND='git show'

	git log --graph --color=always --format="%C(auto)%h %s%d " | \
		fzf --ansi --reverse --height 100% --no-sort --tiebreak=index \
		--preview-window=top:50 --preview "${PREVIEW_COMMAND}" | awk '{print $2}' #\
		# --bind "enter:execute:${ENTER_COMMAND}"
}

alias gs='git status'
alias gd='git diff'
alias gll="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold
green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"

alias gas='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && echo "-----------------" && pwd && git status" ; done'
alias gap='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && echo "-----------------" && pwd && git pull" ; done'
alias gc='git-fzf-checkout'
alias gl='git-fzf-log'

# --- FZF enhanced finding functions ---
fzf_find_file() {
    # nvim `fd --type file --hidden | fzf --preview='bat --color=always {}'`
    # fd --type file --hidden | \
    fzf --preview='bat --color=always {}' \
        --preview-window 'up:60%:border-bottom:~3' \
        --bind 'enter:become(nvim {})'
}

fzf_find_grep() {
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
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
alias ff='fzf_find_file'
alias fg='fzf_find_grep'

# --- Set prompt ---
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 2)\]\t \[$(tput setaf 3)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 5)\]\$(git-parse-branch)\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

# --- FFF cd on exit function ---
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

