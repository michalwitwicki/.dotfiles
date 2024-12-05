define print_params
    continue
    info args
    print_params
end

# set logging file my-gdb-log
# set logging enabled on

# break main
break function_name

run

# info args
# print_params

refresh

# --- Example of starting gdb with script ---
# gdb --tui -q -x ../gdb_script_template.sh --args ./some_app -f some_args.txt
