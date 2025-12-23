#!/bin/bash

# Find all dot files then if the original file exists, create a backup
# Once backed up to {file}.dtbak symlink the new dotfile in place
for file in $(find . -maxdepth 1 -name ".*" -type f  -printf "%f\n" ); do
    if [ -e ~/$file ]; then
        mv -f ~/$file{,.dtbak}
    fi
    ln -s $PWD/$file ~/$file
done

# Packages to install
PACKAGES="vim-scripts zsh zsh-syntax-highlighting zsh-autosuggestions tmux htop"

# Detect package manager and install packages
install_packages() {
    if command -v apt &> /dev/null; then
        echo "Detected Debian/Ubuntu - using apt"
        sudo apt update
        for pkg in $PACKAGES; do
            sudo apt install -y "$pkg" 2>/dev/null || echo "Warning: $pkg not available, skipping"
        done
    elif command -v dnf &> /dev/null; then
        echo "Detected RHEL/Fedora - using dnf"
        for pkg in $PACKAGES; do
            sudo dnf install -y "$pkg" 2>/dev/null || echo "Warning: $pkg not available, skipping"
        done
    elif command -v yum &> /dev/null; then
        echo "Detected RHEL/CentOS - using yum"
        for pkg in $PACKAGES; do
            sudo yum install -y "$pkg" 2>/dev/null || echo "Warning: $pkg not available, skipping"
        done
    else
        echo "Error: No supported package manager found (apt/dnf/yum)"
        exit 1
    fi
}

echo "Installing extras..."
install_packages

# Set up alias file
if [ -f "$PWD/.bash_aliases" ] && [ ! -e ~/.bash_aliases ]; then
    ln -s "$PWD/.bash_aliases" ~/.bash_aliases
fi

echo "Installed"
echo "use chsh -s /bin/zsh to switch to ZSH shell"
