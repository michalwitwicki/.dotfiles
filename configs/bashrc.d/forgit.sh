# --- Forgit settings ---

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

# Forgit command variable bindings
export forgit_add="${forgit_add:-ga}"
export forgit_reset_head="${forgit_reset_head:-grh}"
# export forgit_log="${forgit_log:-glo}"
export forgit_log="${forgit_log:-gl}"
export forgit_diff="${forgit_diff:-gd}"
export forgit_ignore="${forgit_ignore:-gi}"
export forgit_checkout_file="${forgit_checkout_file:-gcf}"
# export forgit_checkout_branch="${forgit_checkout_branch:-gcb}"
export forgit_checkout_branch="${forgit_checkout_branch:-gc}"
export forgit_checkout_commit="${forgit_checkout_commit:-gco}"
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

# Forgit aliases
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
