#!/bin/bash

# Exit on error
set -e

# create log file
touch ./setup.log

# https://nixos.org/
if command -v nix &> /dev/null; then
    echo "Installing nix single user mode..."
    curl -L https://nixos.org/nix/install | sh --no-daemon --yes
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    echo "--> done"
    NIXVERSION=$(nix --version)
    echo "$NIXVERSION is installed." >> ./setup.log
else
    NIXVERSION=$(nix --version)
    echo "$NIXVERSION is installed." >> ./setup.log
fi
# https://devenv.sh/
nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
devenv init

# Install ChromeOS extensions
sudo ./ext vsc
