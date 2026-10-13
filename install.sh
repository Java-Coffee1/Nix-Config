#!/usr/bin/env bash
# Fresh install script for github.com/Java-Coffee1/Nix-Config
#
# On an installed NixOS:
#   sudo bash install.sh              # laptop (fw-nixos-btw)
#   sudo bash install.sh <host>       # any host in ./hosts
#
# From the NixOS ISO (WIPES the disk):
#   sudo bash install.sh <host> <disk>
#   sudo bash install.sh linux-iso-btw /dev/sda
set -euo pipefail

HOST="${1:-fw-nixos-btw}"
DISK="${2:-}"
USER_NAME="javi"
REPO="https://github.com/Java-Coffee1/Nix-Config.git"

# Flakes are off on a fresh install, turn them on for this script only
export NIX_CONFIG="experimental-features = nix-command flakes"

if [ "$EUID" -ne 0 ]; then
  echo "Run this with sudo"
  exit 1
fi

# Installing from the ISO puts everything under /mnt
ROOT=""
if [ -n "$DISK" ]; then
  ROOT="/mnt"
fi
DIR="$ROOT/home/$USER_NAME/Nix-Config"

# git isn't installed on a fresh NixOS, so run it through nix-shell
git() { nix-shell -p git --run "git $*"; }

############################################
## Disk (ISO only)
############################################

if [ -n "$DISK" ]; then
  echo "This will ERASE everything on $DISK"
  read -rp "Type yes to continue: " ANSWER
  if [ "$ANSWER" != "yes" ]; then
    exit 1
  fi

  # /dev/sda -> /dev/sda1, /dev/nvme0n1 -> /dev/nvme0n1p1
  PART="${DISK}1"
  if [[ "$DISK" =~ [0-9]$ ]]; then
    PART="${DISK}p1"
  fi

  parted -s "$DISK" -- mklabel msdos
  parted -s "$DISK" -- mkpart primary 1MB 100%
  parted -s "$DISK" -- set 1 boot on
  udevadm settle

  mkfs.ext4 -F -L nixos "$PART"
  mount /dev/disk/by-label/nixos /mnt
fi

############################################
## Clone
############################################

if [ ! -d "$DIR" ]; then
  mkdir -p "$ROOT/home/$USER_NAME"
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

if [ -n "$DISK" ]; then
  nixos-generate-config --root /mnt --show-hardware-config > "$DIR/hosts/$HOST/hardware-configuration.nix"

  # Point grub at the disk we just set up
  sed -i "s|boot.loader.grub.device = .*|boot.loader.grub.device = \"$DISK\";|" "$DIR/hosts/$HOST/default.nix"
else
  nixos-generate-config --show-hardware-config > "$DIR/hosts/$HOST/hardware-configuration.nix"
fi

# Flakes only see files git knows about
git -C "$DIR" add -A

############################################
## Build and switch
############################################

if [ -n "$DISK" ]; then
  nix-shell -p git --run "nixos-install --no-root-passwd --flake $DIR#$HOST"
  nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME"
else
  nix-shell -p git --run "nixos-rebuild switch --flake $DIR#$HOST"
  chown -R "$USER_NAME:users" "/home/$USER_NAME"
fi

############################################
## Password
############################################

echo "Set a password for $USER_NAME:"
if [ -n "$DISK" ]; then
  nixos-enter --root /mnt -c "passwd $USER_NAME"
else
  passwd "$USER_NAME"
fi

############################################
## Done
############################################

echo
echo "Done. Reboot to log in as $USER_NAME."
echo
echo "Secrets (agenix) won't decrypt until this machine's host key is added."
echo "After rebooting, add this key to secrets/agenix-rules.nix, then run: agenix -r"
echo "  cat /etc/ssh/ssh_host_ed25519_key.pub"