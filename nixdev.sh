#!/bin/bash

# Exit on error
set -e



# remove nix install script
rm ./install

# Install ChromeOS extensions
curl -LO https://raw.githubusercontent.com/torstenboettjer/devenv/main/ext
chmod +x ./ext
sudo ./ext vsc
rm ./ext
