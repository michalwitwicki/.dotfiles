import urllib.request
import os
import tarfile

def download_file(url, path, filename):
    try:
        response = urllib.request.urlopen(url)
        if response.status == 200:
            expanded_path = os.path.expanduser(path)
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
            members = tar.getmembers()
            print("members", members)
            root_dirs = [m for m in members if m.name.count('/') == 0]
            print("root_dirs", root_dirs)
            print("root_dirs len ", len(root_dirs))
            if len(root_dirs) == 1 and root_dirs[0].isdir():
                tar.extractall(path=expanded_extract_path)
            else:
                new_dir = os.path.join(expanded_extract_path, os.path.splitext(os.path.splitext(os.path.basename(file_path))[0])[0])
                os.makedirs(new_dir, exist_ok=True)
                tar.extractall(path=new_dir)
        print(f"File extracted successfully to {expanded_extract_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    files_to_download = {
        "https://github.com/dylanaraps/fff/archive/refs/tags/2.2.tar.gz": "fff.tar.gz",
        # "https://github.com/wfxr/forgit/releases/download/23.09.0/forgit-23.09.0.tar.gz": "forgit.tar.gz",
        # "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz": "neovim.tar.gz",
        # "https://github.com/andreafrancia/trash-cli/archive/refs/tags/0.23.11.10.tar.gz": "trash-cli.tar.gz",
        # "https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz": "delta.tar.gz",
        # "https://github.com/junegunn/fzf/releases/download/0.44.1/fzf-0.44.1-linux_amd64.tar.gz": "fzf.tar.gz",
        # "https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz": "ripgrep.tar.gz",
        "https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-x86_64-unknown-linux-gnu.tar.gz": "fd.tar.gz",
        # "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-gnu.tar.gz": "bat.tar.gz"
    }
    path = "./tools"
    for url, filename in files_to_download.items():
        print("---", filename, "---")
        ret = download_file(url, path, filename)
        if ret is not None:
            extract_tar_gz(ret, path)


# members [
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/CHANGELOG.md' at 0x7fbba18acf40>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/LICENSE-APACHE' at 0x7fbba18ace80>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/LICENSE-MIT' at 0x7fbba18ac940>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/README.md' at 0x7fbba1655100>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/autocomplete' at 0x7fbba1655040>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/autocomplete/bat.bash' at 0x7fbba1655280>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/autocomplete/bat.zsh' at 0x7fbba16551c0>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/autocomplete/bat.fish' at 0x7fbba1655340>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/autocomplete/_bat.ps1' at 0x7fbba16554c0>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/bat' at 0x7fbba1655580>,
#         <TarInfo 'bat-v0.24.0-i686-unknown-linux-gnu/bat.1' at 0x7fbba1655640>
#         ]
