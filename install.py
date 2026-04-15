import os

TOOLS_PATH = "~/tools"

def create_symbolic_link(target, link_name):
    expanded_target_path = os.path.expanduser(target)
    expanded_link_path = os.path.expanduser(link_name)
    try:
        os.symlink(expanded_target_path, expanded_link_path)
        print(f"Symbolic link created: {expanded_link_path} -> {expanded_target_path}")
    except OSError as e:
        print(f"Error creating symbolic link: {e}")

def create_symbolic_links():
    print("--- Create symbolic links ---")
    create_symbolic_link(os.path.join(os.getcwd(), ".tmux.conf"), "~/.tmux.conf")
    create_symbolic_link(os.path.join(os.getcwd(), ".inputrc"), "~/.inputrc")
    create_symbolic_link(os.path.join(os.getcwd(), "nvim"), "~/.config/nvim")
    create_symbolic_link(os.path.join(os.getcwd(), ".gdbinit"), "~/.gdbinit")

def check_if_string_in_file(file_path, target_string):
    expanded_file_path = os.path.expanduser(file_path)
    try:
        with open(expanded_file_path, 'r') as file:
            content = file.read()
            if target_string in content:
                print(f"The specified string: \n'{target_string}' \nwas found in the file.")
                return True
            else:
                print(f"The specified string \n'{target_string}' \nwas not found in the file.")
                return False
    except FileNotFoundError:
        print(f"Error: File '{expanded_file_path}' not found.")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def append_line_to_file(file_path, new_line):
    expanded_file_path = os.path.expanduser(file_path)
    try:
        with open(expanded_file_path, 'a') as file:
            file.write('\n')  # Append a new line
            file.write(new_line)  # Append the provided string
            file.write('\n')  # Append a new line
            print(f"New line and string appended to '{expanded_file_path}'.")
    except Exception as e:
        print(f"Error: {e}")

def add_to_file_if_not_there(file_to_check, string_to_add):
    if check_if_string_in_file(file_to_check, string_to_add) == False:
        append_line_to_file(file_to_check, string_to_add)

def include_configs():
    print("--- Include configs ---")
    # bashrc
    file_to_include_path = os.path.join(os.getcwd(), ".bashrc")
    string_to_add = "[ -f " + file_to_include_path + " ] && source " + file_to_include_path
    file_to_check = "~/.bashrc"
    add_to_file_if_not_there(file_to_check, string_to_add)

    # gitconfig
    file_to_include_path = os.path.join(os.getcwd(), ".gitconfig")
    string_to_add = "[include]\n    path = " + file_to_include_path
    file_to_check = "~/.gitconfig"
    add_to_file_if_not_there(file_to_check, string_to_add)


if __name__ == "__main__":
    # download_and_extract_tools()
    create_symbolic_links()
    include_configs()
