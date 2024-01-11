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
    files_to_download = {
        "https://github.com/dylanaraps/fff/archive/refs/tags/2.2.tar.gz": "fff",
        "https://github.com/wfxr/forgit/releases/download/23.09.0/forgit-23.09.0.tar.gz": "forgit",
        "https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz": "neovim",
        "https://github.com/andreafrancia/trash-cli/archive/refs/tags/0.23.11.10.tar.gz": "trash-cli",
        "https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz": "delta",
        "https://github.com/junegunn/fzf/releases/download/0.44.1/fzf-0.44.1-linux_amd64.tar.gz": "fzf",
        "https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz": "ripgrep",
        "https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-x86_64-unknown-linux-gnu.tar.gz": "fd",
        "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-gnu.tar.gz": "bat"
    }
    path = TOOLS_PATH
    for url, filename in files_to_download.items():
        print("---", filename, "---")
        ret = download_file(url, path, filename, ".tar.gz")
        if ret is not None:
            extract_tar_gz(ret, path)

if __name__ == "__main__":
    download_and_extract_tools()
