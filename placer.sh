#!/bin/bash
#This script makes links to config files from appropriate places

target_path=$(cd `dirname $0` && pwd)


declare -a dest_paths
declare -a config_files_names

#bashrc
dest_paths+=("$HOME")
config_files_names+=(".bashrc")

#profile
dest_paths+=("$HOME")
config_files_names+=(".profile")

#tmux
dest_paths+=("$HOME")
config_files_names+=(".tmux.conf")

#alacritty
dest_paths+=("$HOME/.config/alacritty")
config_files_names+=("alacritty.yml")

#nvim
dest_paths+=("$HOME/.config/nvim")
config_files_names+=("init.vim")

#lf
dest_paths+=("$HOME/.config/lf")
config_files_names+=("lfcd.sh")


for(( i=0; i<${#dest_paths[@]}; i++ ));
do
    path=${dest_paths[$i]}
    file=${config_files_names[$i]}
    echo -e "$((i+1)). $file \t--> $path"

    rm -f "$path/$file"
    mkdir -p "$path"
    ln -s "$target_path/$file" "$path"
done

echo -e "\nDone!"


