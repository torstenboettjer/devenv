#!/usr/bin/env bash

# Exit on error
set -e

# create log file
touch ./setup.log

#######################################
# devenv.sh incl. nix
#######################################
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

# Select functions
main() {
    install_devenv
    sudo ./ext.sh
}

# Execute main function with all the command-line arguments
main "$@"
