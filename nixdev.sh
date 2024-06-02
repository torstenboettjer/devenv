#!/usr/bin/env bash

# Constants
readonly CMD_SHUTDOWN="shutdown -P now; init 0"

# Exit on error
set -e

# create log file
touch ./setup.log

#######################################
# System Update
#######################################
update() {
    echo "Updating Linux Environment"
    apt update && apt upgrade -y && apt autoremove -y && apt autoclean -y
    echo "Prepare: System update" >> ./setup.log
}

install_devenv() {
    if command -v nix &> /dev/null; then
        NIXVERSION=$(nix --version)
        echo "$NIXVERSION is installed." >> ./setup.log
    else
        echo "Installing nix single user mode..."
        sh <(curl -L https://nixos.org/nix/install) --no-daemon --yes
        . $HOME/.nix-profile/etc/profile.d/nix.sh
        echo "--> done"
        NIXVERSION=$(nix --version)
        echo "$NIXVERSION is installed." >> ./setup.log
    fi
    nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
    devenv init
}

#######################################
# Visual Studio Code
#######################################
install_vsc() {
    echo "Installing VSCode"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    apt install apt-transport-https
    apt update
    apt install code -y
    echo "Installed Visual Code" >> ./setup.log
}

# Select functions
main() {
    # Minimal install
    update
    install_devenv
    install_vsc
}

# Execute main function with all the command-line arguments
main "$@"
