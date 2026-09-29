#!/usr/bin/env bash
# Fresh install script for github.com/Java-Coffee1/Nix-Config
# Run on a fresh NixOS install:
#   sudo bash install.sh              # laptop (fw-nixos-btw)
#   sudo bash install.sh <host>       # any host in ./hosts
set -euo pipefail

HOST="${1:-fw-nixos-btw}"
USER_NAME="javi"
REPO="https://github.com/Java-Coffee1/Nix-Config.git"
DIR="/home/$USER_NAME/Nix-Config"

# Flakes are off on a fresh install, turn them on for this script only
export NIX_CONFIG="experimental-features = nix-command flakes"

if [ "$EUID" -ne 0 ]; then
  echo "Run this with sudo"
  exit 1
fi

# git isn't installed on a fresh NixOS, so run it through nix-shell
git() { nix-shell -p git --run "git $*"; }

############################################
## Clone
############################################

if [ ! -d "$DIR" ]; then
  mkdir -p "/home/$USER_NAME"
  git clone "$REPO" "$DIR"
fi

if [ ! -d "$DIR/hosts/$HOST" ]; then
  echo "No host called $HOST, pick one of:"
  ls "$DIR/hosts"
  exit 1
fi

############################################
## Hardware config for this machine
############################################

nixos-generate-config --show-hardware-config > "$DIR/hosts/$HOST/hardware-configuration.nix"

# Flakes only see files git knows about
git -C "$DIR" add -A

############################################
## Build and switch
############################################

nix-shell -p git --run "nixos-rebuild switch --flake $DIR#$HOST"

chown -R "$USER_NAME:users" "/home/$USER_NAME"

############################################
## Password
############################################

echo "Set a password for $USER_NAME:"
passwd "$USER_NAME"

############################################
## Done
############################################

echo
echo "Done. Reboot to log in as $USER_NAME."
echo
echo "Secrets (agenix) won't decrypt until this machine's host key is added."
echo "Add this key to secrets/secrets.nix, then run: agenix -r"
cat /etc/ssh/ssh_host_ed25519_key.pub