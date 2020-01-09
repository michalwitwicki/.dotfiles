#!/bin/bash
#This script will make links to config files from appropriate places

#Destination paths
bashrch_path="$HOME"
tmux_conf_path="$HOME"
alacritty_conf_path="$HOME/.config/alacritty"
nvim_conf_path="$HOME/.config/nvim"
test_path="$HOME/test_dir"

#Test
rm -f "$test_path/test_file"
mkdir -p "$test_path"
ln -s "$HOME/test_target" "$test_path"

#.bashrc
rm -f "$bashrch_path/.bashrc"
mkdir -p "$bashrch_path"
ln -s "$PWD/.bashrc" "$bashrch_path"

