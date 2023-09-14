#!/bin/sh

PATH_TO_LOG_FILE=`pwd`"/log_file"
PATH_TO_TMP_FILE="/tmp/fzf_cd_tmp"
CURRENT_PATH=`pwd`"/"
STARTING_PATH=`pwd`"/"
SELECTED=""

# Create tmp file with current path inside and previous action
# printf %s $CURRENT_PATH > $PATH_TO_TMP_FILE
echo $CURRENT_PATH > $PATH_TO_TMP_FILE
# echo "OPENED" >> $PATH_TO_TMP_FILE

function change_nth_line() #file, line number, text
{
    sed -i "${2}s/.*/${3}/" ${1}
}
# change_nth_line $PATH_TO_TMP_FILE 1 ""

function append_to_nth_line() #file, line number, text
{
    sed -i "${2}s/.*/&${3}/" ${1}
}
# append_to_nth_line $PATH_TO_TMP_FILE 2 kopytko

function get_nth_line() #file, line number
{
    sed -n "${2}p" ${1}
}
# ret=$(get_nth_line $PATH_TO_TMP_FILE 2)
# echo $ret

# Create log file
true > $PATH_TO_LOG_FILE

# if [ -z "$EDITOR" ]
# then
#     EDITOR=vim
# fi
#
# function get_nth_line() #file, line number
# {
#     return `sed "${2}q;d" ${1}`
# }
#
# echo `get_nth_line README.md 10`
# exit 1

while true 
do
    # SELECTED=$(CLICOLOR_FORCE=1 ls -Fa | fzf)
    CURRENT_PATH=`pwd`"/"
    
    # CURRENT_PATH="`cat $PATH_TO_TMP_FILE`"
    # CURRENT_PATH=$(get_nth_line $PATH_TO_TMP_FILE 1)
    # CURRENT_BASENAME="`

    PREV_LEFT_DIR=$(get_nth_line $PATH_TO_TMP_FILE 2)
    # APPEND_TO_2_LINE=$(append_to_nth_line $PATH_TO_TMP_FILE 1 {})
    # SELECTED=$(ls $CURRENT_PATH -Fa | fzf \
    SELECTED=$(ls -Fa | fzf \
        --cycle \
        --query="$PREV_LEFT_DIR" \
        --bind="enter:execute(printf %s {} >> $PATH_TO_TMP_FILE)+accept" \
        --bind="ctrl-l:execute(cd {})" \
        --bind="ctrl-h:execute(printf %s "../" >> $PATH_TO_TMP_FILE)+accept"
        # --bind="enter:execute(printf %s {} >> $PATH_TO_TMP_FILE)+accept" \
        # --bind="ctrl-l:execute(printf %s {} >> $PATH_TO_TMP_FILE)+accept" \
        # --bind="ctrl-h:execute(printf %s "../" >> $PATH_TO_TMP_FILE)+accept"
        # --bind="ctrl-c:cancel"
    )

    # Simplify a path to execute
    CURRENT_PATH="`cat $PATH_TO_TMP_FILE`"
    CURRENT_PATH="`realpath --zero --quiet $CURRENT_PATH`"
    # printf %s $CURRENT_PATH"/" > $PATH_TO_TMP_FILE
    change_nth_line $PATH_TO_TMP_FILE 1 $CURRENT_PATH


    echo "SELECTED: $SELECTED" >> $PATH_TO_LOG_FILE
    echo "CURRENT_PATH: $CURRENT_PATH" >> $PATH_TO_LOG_FILE

    if [ -z "$SELECTED" ]
    then
        echo "mamy breaka" >> $PATH_TO_LOG_FILE
        break
    fi

    if [ -d "$CURRENT_PATH" ]
    then
        echo "jestesmy w cd" >> $PATH_TO_LOG_FILE
        echo "PATH TO EXECUTE: $CURRENT_PATH" >> $PATH_TO_LOG_FILE
        cd $CURRENT_PATH
    else
        echo "jestesmy w odpaleniu vima" >> $PATH_TO_LOG_FILE
        $EDITOR $CURRENT_PATH
    fi

done



# Remove tmp file
\rm $PATH_TO_TMP_FILE
