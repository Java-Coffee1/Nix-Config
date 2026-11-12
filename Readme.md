# Java learns nixos 

This is my Personal NixOs setup for my laptop and homelab.

> ⚠️ This is very custom to me, so I don't recommend installing it as is. Feel free to steal snippets though!

## Hosts

| Host | What it is |
|------|------------|
| `fw-nixos-btw` | My Framework laptop (Hyprland desktop) |
| `homelab-nixos-btw` | Homelab server (Traefik, Jellyfin, Immich, etc.) |
| `javi-email` | Email server |

##

## Repo layout

```
flake.nix       # entry point, defines every host
hosts/          # one folder per machine
home/           # home-manager config (dotfiles) for my user
modules/        # shared NixOS modules (apps, lab services, torrenting)
secrets/        # agenix encrypted secrets
lazy-scripts/   # little helper scripts
install.sh      # one-command installer
```

## Install

You need NixOS installed first.

**On an existing NixOS machine:**

```
sudo bash -c "$(nix-shell -p curl --run 'curl -fsSL https://raw.githubusercontent.com/Java-Coffee1/Nix-Config/main/install.sh')"
```

or clone it and run it yourself:

```
git clone https://github.com/Java-Coffee1/Nix-Config
cd Nix-Config
sudo bash install.sh <host>
```

**Fresh install from the NixOS ISO** (⚠️ this WIPES the disk):

```
sudo bash install.sh <host> /dev/sda
```

## After install: secrets

Secrets (like the WireGuard key) are encrypted with [agenix](https://github.com/ryantm/agenix) and won't decrypt until the new machine's key is added.

1. Get the host key:
   ```
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```
2. Add it to `secrets/agenix-rules.nix`, then re-encrypt:
   ```
   agenix -r
   ```
3. To set the WireGuard private key:
   ```
   agenix -e wg-private-fw.age
   ```

**Clean up old generations:**
```
sudo nix-collect-garbage -d
```
## Overview video of my homlab
[![Nix Config Overview](https://fs.jv.ax/chaosbox/Nix-Config-Overview/Nix-Config-Overview.mp4)]