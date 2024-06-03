# Minimal Development Environment on a Chromebook

Creating a minimal developer environment on a Chromebook utilizes `devenv.sh` on Linux (Crostini). Installing and configuring the devenv shell requires the following steps:

## Step 1: Enable Linux (Crostini)

1. **Open Settings**:
   - Click on the clock in the bottom-right corner of the screen to open the system menu.
   - Click on the gear icon to open Settings.

2. **Turn On Linux (Beta)**:
   - In the left-hand sidebar, click on `Developers`.
   - Find the `Linux development environment` section and click `Turn On`.
   - Follow the prompts to set up Linux. This will install a Debian-based Linux container on your Chromebook. 
   - The default disk appears rather small, we recommend at least 50GB space for virtual environments created by devenv.sh

## Step 2: Install Nix package manager and `devenv.sh` 

Create a script called `nixdev.sh` will install and configure a development environment. This script should be tailored to specific needs, but here’s a basic example that includes the installation of VS Code:

```sh
curl -sL https://raw.githubusercontent.com/torstenboettjer/devenv/main/nixdev.sh | sh

The shell ist started with `devenv shell` and stopped with CTRL+D.

```

## Remove

For the removal of the devenv shell, please refer to the 'nixrm' script.

```sh
curl -sL https://raw.githubusercontent.com/torstenboettjer/devenv/main/nixrm.sh | sh
```

### Toolset

* [Linux Development Environment](https://chromeos.dev/en/linux)
* [VS Code](https://code.visualstudio.com/docs/setup/linux)
* [NixOS](https://nixos.org/)
* [devenv.sh](https://devenv.sh/)
* [process-compose](https://f1bonacc1.github.io/process-compose/)
