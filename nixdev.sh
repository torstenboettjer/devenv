#!/bin/bash

# Exit on error
set -e

# create log file
touch ./setup.log

# https://nixos.org/
if command -v nix &> /dev/null; then
    echo "Installing nix single user mode..."
    curl -LO https://nixos.org/nix/install
    chmod +x ./install
    ./install --no-daemon --yes
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

# remove nix install script
rm ./install

# Install ChromeOS extensions
curl -LO https://raw.githubusercontent.com/torstenboettjer/devenv/main/ext
chmod +x ./ext
sudo ./ext vsc
rm ./ext
