import urllib.request
import os
import tarfile

TOOLS_PATH = "~/tools"

def download_file(url, path, filename, filename_suffix):
    try:
        response = urllib.request.urlopen(url)

        if response.status == 200:
            expanded_path = os.path.expanduser(path)
            filename = filename + filename_suffix
            os.makedirs(expanded_path, exist_ok=True)
            full_path = os.path.join(expanded_path, filename)
            urllib.request.urlretrieve(url, full_path)
            print(f"File downloaded successfully as {full_path}")
            return full_path
        else:
            print(f"Unable to reach the URL: {url}")
            return None

    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def extract_tar_gz(file_path, extract_path='.'):
    try:
        expanded_file_path = os.path.expanduser(file_path)
        expanded_extract_path = os.path.expanduser(extract_path)

        with tarfile.open(expanded_file_path, 'r:gz') as tar:
            new_dir = os.path.join(expanded_extract_path, os.path.basename(file_path).split('.')[0])
            os.makedirs(new_dir, exist_ok=True)
            tar.extractall(path=new_dir)
            os.remove(expanded_file_path)

        print(f"File {expanded_file_path} extracted successfully to {new_dir}")

    except Exception as e:
        print(f"An error occurred: {e}")

def download_and_extract_tools():
    print("--- Download and extract tools ---")
    files_to_download = {
        "https://github.com/dylanaraps/fff/archive/refs/tags/2.2.tar.gz": "fff",
        "https://github.com/wfxr/forgit/releases/download/24.01.0/forgit-24.01.0.tar.gz": "forgit",
        # "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz": "neovim",
        # "https://github.com/andreafrancia/trash-cli/archive/refs/tags/0.23.11.10.tar.gz": "trash-cli",
        # "https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz": "delta",
        # "https://github.com/junegunn/fzf/releases/download/0.44.1/fzf-0.44.1-linux_amd64.tar.gz": "fzf",
        # "https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz": "ripgrep",
        # "https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-x86_64-unknown-linux-gnu.tar.gz": "fd",
        # "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-gnu.tar.gz": "bat"
    }
    path = TOOLS_PATH
    for url, filename in files_to_download.items():
        print("---", filename, "---")
        ret = download_file(url, path, filename, ".tar.gz")
        if ret is not None:
            extract_tar_gz(ret, path)

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
