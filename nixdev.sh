#!/usr/bin/env bash

# Constants
readonly CMD_SHUTDOWN="shutdown -P now; init 0"

# Exit on error
set -e

# create log file
touch ./setup.log


#######################################
# Check if the script is run with sudo
#######################################
sudo_check() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo."
        exit 1
    fi
}

#######################################
# Python incl. developer tools
#######################################
install_devtools() {
    echo "Installing Development Tools"
    apt install -y build-essential libssl-dev libnss3-dev libffi-dev make nano python3-pip curl wget gpg
    PYTHON_VERSION=$(python3 --version)
    echo "Python: $PYTHON_VERSION" >> ./setup.log
}

#######################################
# Config git client
#######################################
config_git() {
    GIT_VERSION=$(git --version)
    echo "Git: $GIT_VERSION", global config nano; $1; $2" >> ./setup.log
    git config --global core.editor 'nano'
    git config --global user.name '$1'
    git config --global user.email '$2'
}

install_gh() {
    apt install gh -y
    GH_VERSION=$(gh --version)
    echo "Github: $GH_VERSION" >> ./setup.log
}

install_nxm() {
    echo "Installing nix as daemon, after install the shell session will be closed."
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    echo "Nix installed, restarting ..."
    $CMD_SHUTDOWN
}

#######################################
# Docker AMD
#######################################
install_docker() {
    clear
    echo "Installing Docker"
    apt update && apt install -y docker.io
    usermod -aG docker $1
    docker_grp="newgrp docker"
    # Execute the command as the specified user using sudo
    sudo -u "$1" $docker_grp
    systemctl enable docker.service
    DKR_VERSION=$(docker version)
    echo "$DKR_VERSION" >> ./setup.log
}

#######################################
# DevPod AMD
#######################################
install_devpod() {
    echo "Installing DevPod"
    curl -L -o devpod https://github.com/loft-sh/devpod/releases/latest/download/DevPod_linux_amd64.AppImage \
        && chmod +x ./devpod \
        && mv ./devpod /opt/devpod
    echo "DevPod UI is installed in /opt/devpod" >> ./setup.log
    curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" \
        && install -c -m 0755 devpod /usr/local/bin \
        && rm -f devpod
        DVP_VERSION=$(devpod version)
        echo "$DVP_VERSION" >> ./setup.log
}

#######################################
# Snap application store
#######################################
option_snapd() {
    clear
    echo "Installing snap"
    apt install libsquashfuse0 squashfuse fuse snapd -y
    systemctl enable --now snapd.apparmor
    #chgrp -R root /var
    SNAP_VERSION=$(snap version)
    echo "Installed $SNAP_VERSION" >> ./setup.log
}

#######################################
# Terraform
#######################################
option_terraform() {
    clear
    echo "Installing Terraform"
    apt install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install terraform -y
    TF_VERSION=$(terraform version)
    echo "Installed Terraform $TF_VERSION" >> ./setup.log
}

#######################################
# Install Rust
#######################################
install_rust() {
    echo "Installing rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup install stable
    rustup default stable
    rustup component add rust-src
    apt install build-essential
    RUST_VERSION=$(rustc --version)
    RUSTUP_VERSION=$(rustup --version)
    echo "Installed RUST $RUST_VERSION and RUSTUP $RUSTUP_VERSION" >> ./setup.log
}

#######################################
# PostgreSQL
#######################################
install_psql() {
    echo "Installing PostgreSQL"
    apt install -y postgresql
    apt install -y postgresql-contrib
    PSQL_VERSION=$(psql --version)
    echo "Installed PSQL $PSQL_VERSION" >> ./setup.log
}

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
