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

curl -LO https://raw.githubusercontent.com/torstenboettjer/devenv/main/extos
chmod +x ./extos

# Install optional extensions to ChromeOS
if direnv --version &> /dev/null; then
    apt install direnv -y
    echo 'eval "$(direnv hook bash)"' >> /home/$USER/.bashrc
    echo 'export DIRENV_LOG_FORMAT=""' >> /home/$USER/.bashrc
    DIRENV_VERSION=$(direnv --version)
    echo "$DIRENV_VERSION is installed." >> ./setup.log
else
    DIRENV_VERSION=$(direnv --version)
    echo "$DIRENV_VERSION is installed." >> ./setup.log
fi

#https://nixos.wiki/wiki/Home_Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
echo '. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"' >>  ~/.profile
home-manager build
