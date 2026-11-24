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

flake.nix       # entry point, defines every host
hosts/          # one folder per machine
home/           # home-manager config (dotfiles) for my user
modules/        # shared NixOS modules (apps, lab services, torrenting)
secrets/        # agenix encrypted secrets
lazy-scripts/   # little helper scripts
install.sh      # one-command installer

Full tree (regenerate with `lazy-scripts/gen-readme-tree.sh`):

<!-- repo-tree:start -->
```
.
├── home
│   └── javi
│       ├── dotfiles
│       │   ├── dolphin
│       │   │   └── color-schemes
│       │   │       └── OrchisDark.colors
│       │   ├── hyprland
│       │   │   ├── hyprland.lua
│       │   │   ├── keybindings.lua
│       │   │   ├── var.lua
│       │   │   └── windows_and_workspaces.lua
│       │   ├── kitty
│       │   │   ├── carbonfox.conf
│       │   │   └── kitty.conf
│       │   ├── kvantum
│       │   │   ├── Default#
│       │   │   │   └── Default#.kvconfig
│       │   │   ├── Orchis
│       │   │   │   ├── OrchisDark.kvconfig
│       │   │   │   ├── OrchisDark.svg
│       │   │   │   ├── Orchis.kvconfig
│       │   │   │   └── Orchis.svg
│       │   │   ├── Utterly-Nord
│       │   │   │   ├── LICENSE.md
│       │   │   │   ├── Nord.patchconfig
│       │   │   │   ├── Utterly-Nord.kvconfig
│       │   │   │   └── Utterly-Nord.svg
│       │   │   └── kvantum.kvconfig
│       │   ├── noctalia
│       │   │   └── noctalia-config.toml
│       │   ├── nvim
│       │   │   └── init.lua
│       │   ├── qmk
│       │   │   └── framework-macropad
│       │   │       ├── config.h
│       │   │       ├── keymap.c
│       │   │       └── readme.md
│       │   ├── vim
│       │   │   └── vimrc
│       │   └── yazi
│       │       ├── keymap.toml
│       │       ├── theme.toml
│       │       └── yazi.toml
│       ├── home.nix
│       └── javi-options.nix
├── hosts
│   ├── code-nixos-btw
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── fw-nixos-btw
│   │   ├── default.nix
│   │   ├── hardware-configuration.nix
│   │   └── wireguard.nix
│   ├── homelab-nixos-btw
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── javi-email
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── linux-iso-btw
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── nas-nixos-btw
│   │   ├── default.nix
│   │   └── disko.nix
│   ├── net-nixos-btw
│   │   └── default.nix
│   └── server12-nixos-btw
│       └── default.nix
├── lazy-scripts
│   ├── fw
│   │   ├── app-focus-or-launch.nix
│   │   ├── ipad-monitor.nix
│   │   └── macropad.nix
│   ├── lab
│   │   ├── bash-scripts
│   │   │   └── auth-invite.sh
│   │   ├── auth-invite.nix
│   │   ├── default.nix
│   │   ├── gitea-backup.nix
│   │   ├── immich-backup.nix
│   │   ├── jellyfin-backups.nix
│   │   ├── outline-databackup.nix
│   │   ├── postgres-backup.nix
│   │   ├── readme.md
│   │   └── shel-backup-server.nix
│   ├── fix-wifi.sh
│   └── gen-readme-tree.sh
├── modules
│   ├── apps
│   │   ├── discord.nix
│   │   ├── eez-studio.nix
│   │   ├── firefox.nix
│   │   ├── first-driver-station.nix
│   │   ├── git.nix
│   │   ├── mixxx.nix
│   │   ├── neovim.nix
│   │   ├── open-ds.nix
│   │   ├── steam.nix
│   │   ├── vs-code.nix
│   │   └── vsvscodium.nix
│   ├── code-nixos-btw
│   │   ├── claude.nix
│   │   ├── llama.nix
│   │   └── pi.nix
│   ├── email
│   │   └── salwart.nix
│   ├── lab
│   │   ├── traefik-config
│   │   │   ├── middlewares.nix
│   │   │   ├── routes.nix
│   │   │   └── tcp.nix
│   │   ├── virtualization
│   │   │   ├── dumdo.nix
│   │   │   └── vaultwarden.nix
│   │   ├── authentik.nix
│   │   ├── copyparty.nix
│   │   ├── email-server.nix
│   │   ├── gitea.nix
│   │   ├── granfana.nix
│   │   ├── immich.nix
│   │   ├── jellyfin.nix
│   │   ├── navidrome.nix
│   │   ├── outline.nix
│   │   ├── postgress.nix
│   │   ├── traefik.nix
│   │   └── website.nix
│   ├── linux-iso
│   │   ├── nixflix.nix
│   │   └── qbittorrent.nix
│   ├── nas
│   │   └── default.nix
│   ├── activate-nix.nix
│   ├── default.nix
│   └── fw-modules.nix
├── overlay
│   └── default.nix
├── secrets
│   ├── fw-nixos-btw
│   │   └── wg-private-fw.age
│   ├── homelab-nixos-btw
│   │   ├── authentik-env.age
│   │   ├── authentik-ldap-env.age
│   │   ├── authentik-token.age
│   │   ├── backup-env.age
│   │   ├── backup-ssh-key.age
│   │   ├── cf_api_token.age
│   │   ├── copyparty-oauth-client.age
│   │   ├── copyparty-oauth-cookie.age
│   │   ├── gitea-env.age
│   │   ├── gitlab-env.age
│   │   ├── grafana-oidc-secret.age
│   │   ├── grafana-secret-key.age
│   │   ├── mailjet_email_token.age
│   │   ├── outline-oidc.age
│   │   ├── outline-secret-key.age
│   │   ├── outline-utils-secret.age
│   │   ├── postgres-password.age
│   │   └── yt-dl-password.age
│   ├── linux-iso-btw
│   │   ├── lidarr-api-key.age
│   │   ├── prowlarr-api-key.age
│   │   ├── qbittorrent-password.age
│   │   ├── radarr-api-key.age
│   │   ├── seerr-api-key.age
│   │   ├── seerr-jellyfin-admin-password.age
│   │   ├── servarr-env.age
│   │   ├── sonarr-api-key.age
│   │   └── windscribe-wg.age
│   └── agenix-rules.nix
├── flake.lock
├── flake.nix
├── install.sh
├── Readme.md
├── todo.md
└── treefmt.nix

45 directories, 132 files
```
<!-- repo-tree:end -->

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
   agenix -e fw-nixos-btw/wg-private-fw.age
   ```

**Clean up old generations:**
```
sudo nix-collect-garbage -d
```
## Overview video of my homelab
[![Nix Config Overview](https://fs.jv.ax/chaosbox/Nix-Config-Overview/thumbnail.png)](https://fs.jv.ax/chaosbox/Nix-Config-Overview/Nix-Config-Overview.mp4)


