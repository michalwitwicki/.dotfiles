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
export FZF_DEFAULT_COMMAND='fd --type file --hidden'
export FZF_DEFAULT_OPTS=''

# --- FORGIT settings ---
# enable Forgit
export FORGIT_NO_ALIASES=1
export FORGIT_GLO_FORMAT='%C(auto)%h %s%d %C(black)%C(bold)%cr%Creset'
source ~/tools/forgit/forgit.plugin.sh

export FORGIT_MY_COMMON_SETTINGS="
--height '100%'
--preview-window=top:90%
"
export FORGIT_LOG_FZF_OPTS="
$FORGIT_MY_COMMON_SETTINGS
"

export FORGIT_DIFF_FZF_OPTS="
$FORGIT_MY_COMMON_SETTINGS
"
export FORGIT_ADD_FZF_OPTS="
$FORGIT_MY_COMMON_SETTINGS
"
export FORGIT_CHERRY_PICK_FZF_OPTS="
$FORGIT_MY_COMMON_SETTINGS
"
export FORGIT_CHERRY_PICK_FROM_BRANCH_FZF_OPTS="
$FORGIT_MY_COMMON_SETTINGS
"
export FORGIT_CHECKOUT_BRANCH_FZF_OPTS="
--height '50%'
--preview-window=top:50%
"
export FORGIT_CHERRY_PICK_GIT_OPTS="-s -x"

# set Forgit aliases
export forgit_add="${forgit_add:-ga}"
export forgit_reset_head="${forgit_reset_head:-grh}"
# export forgit_log="${forgit_log:-glo}"
export forgit_log="${forgit_log:-gl}"
export forgit_diff="${forgit_diff:-gd}"
export forgit_ignore="${forgit_ignore:-gi}"
export forgit_checkout_file="${forgit_checkout_file:-gcf}"
# export forgit_checkout_branch="${forgit_checkout_branch:-gcb}"
export forgit_checkout_branch="${forgit_checkout_branch:-gc}"
# export forgit_checkout_commit="${forgit_checkout_commit:-gco}"
export forgit_checkout_commit="${forgit_checkout_commit:-gcc}"
export forgit_checkout_tag="${forgit_checkout_tag:-gct}"
export forgit_branch_delete="${forgit_branch_delete:-gbd}"
export forgit_revert_commit="${forgit_revert_commit:-grc}"
export forgit_clean="${forgit_clean:-gclean}"
export forgit_stash_show="${forgit_stash_show:-gss}"
export forgit_stash_push="${forgit_stash_push:-gsp}"
export forgit_cherry_pick="${forgit_cherry_pick:-gcp}"
export forgit_rebase="${forgit_rebase:-grb}"
export forgit_fixup="${forgit_fixup:-gfu}"
export forgit_blame="${forgit_blame:-gbl}"

alias "${forgit_add}"='forgit::add'
alias "${forgit_reset_head}"='forgit::reset::head'
alias "${forgit_log}"='forgit::log'
alias "${forgit_diff}"='forgit::diff'
alias "${forgit_ignore}"='forgit::ignore'
alias "${forgit_checkout_file}"='forgit::checkout::file'
alias "${forgit_checkout_branch}"='forgit::checkout::branch'
alias "${forgit_checkout_commit}"='forgit::checkout::commit'
alias "${forgit_checkout_tag}"='forgit::checkout::tag'
alias "${forgit_branch_delete}"='forgit::branch::delete'
alias "${forgit_revert_commit}"='forgit::revert::commit'
alias "${forgit_clean}"='forgit::clean'
alias "${forgit_stash_show}"='forgit::stash::show'
alias "${forgit_stash_push}"='forgit::stash::push'
alias "${forgit_cherry_pick}"='forgit::cherry::pick::from::branch'
alias "${forgit_rebase}"='forgit::rebase'
alias "${forgit_fixup}"='forgit::fixup'
alias "${forgit_blame}"='forgit::blame'

# --- FZF enhanced finding functions ---
# source "$(dirname "$BASH_SOURCE")/git_fzf_scripts"
fzf_find_file() {
    # nvim `fd --type file --hidden | fzf --preview='bat --color=always {}'`
    # fd --type file --hidden | \
    fzf --preview='bat --color=always {}' \
        --preview-window 'up:60%:border-bottom:~3' \
        --bind 'enter:become(nvim {})'
}

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

# --- Aliases ---
alias v='nvim'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias rs='rsync --exclude=.git --info=progress2 --stats -H -azr'

# warning to use trash-cli instead of rm
alias rm='  echo "This is not the command you are looking for."
            echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
            echo "If you in desperate need of rm use this -> \rm"; false'

alias gds='git diff --staged'
alias gll="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold
green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"

alias gs='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && printf "REPO:" && pwd && git status && echo "---------------------------------------------------"" ; done'
alias gp='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && printf "REPO:" && pwd && git pull && echo "---------------------------------------------------"" ; done'
alias gcm='git commit'
alias gcma='git commit --amend'
alias grbc='git rebase --continue'
alias gcpc='git cherry-pick --continue'

alias ff='fzf_find_file'
alias fs='fzf_find_grep'

# --- "Rsync makes life easier" the script ---
rsync_pass_file()
{
    FILE=~/pass
    if [ ! -f "$FILE" ]; then
        echo "$FILE does not exist."
        return
    fi

    # sshpass -f "$FILE" rsync --exclude=.git --exclude='*cscope*' --info=progress2 -azvh "$@"
    sshpass -f "$FILE" rsync --exclude='*cscope*' --info=progress2 -azvh "$@"
}
alias rsp='rsync_pass_file'

# --- Set prompt ---
git_parse_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 2)\]\t \[$(tput setaf 3)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 5)\]\$(git_parse_branch)\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

# --- FFF cd on exit function ---
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

