# Java learns nixos 
This is my personal dot files for my laptop. I do not recommand installing these dot files as they are extreamly custom to me. however feel free to to take sinipts of my config. 

##
Install 

Clone the repo in a folder

Also make sure you have nixos installed.
```
git clone github.com/Java-Coffee1/Nix-Config
```
link repo 
```
ln -s /your/home/dir/Nix-Config/flake.nix /etc/nixos/flake.nix
```

## Wireguard
agenix 
run this and paste your private key
```
agenix -e -r wg-private-fw.age put public wg key here 
```
## Install 

```
sudo nixos-rebuild switch
```

sudo nix-collect-garbage -d

## Install more info 
this is for my laptop 
```
nixos-rebuild switch --flake .#nixos-btw --sudo
```
this is for a remote 
```
nixos-rebuild switch --flake .#server1 --target-host javi@server1 --sudo
```

## Testing
git add -A
nix flake check

nixos-rebuild dry-build --flake .#nixos-btw

folder strut 
```
Nix-Config/
├── flake.nix
├── flake.lock
│
├── hosts/                          # one folder per machine
│   ├── fw-nixos-btw/
│   │   ├── default.nix             # imports + host-specific bits
│   │   └── hardware-configuration.nix
│   ├── homelab-nixos-btw/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── pi/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/                        # NixOS layer — services, system state
│   ├── core.nix                    # nix settings, locale, users, ssh
│   ├── desktop/
│   │   ├── hyprland.nix
│   │   └── audio.nix
│   ├── apps/
│   │   ├── vscode.nix
│   │   └── treefmt.nix
│   └── server/
│       ├── docker.nix
│       └── wireguard.nix
│
├── home/                           # $HOME layer — Hjem file entries
│   └── javi/
│       ├── common.nix              # zsh, git, tmux — every host
│       ├── desktop.nix             # hyprland.lua, kitty.conf, quickshell
│       └── dotfiles/               # the actual files, verbatim
│           ├── kitty.conf
│           ├── hypr/
│           │   ├── hyprland.lua
│           │   └── keybindings.lua
│           └── zsh/.zshrc
│
└── secrets/
    ├── secrets.nix
    └── wg-private-fw.age

```Nix-Config/
├── flake.nix
├── flake.lock
│
├── hosts/                          # one folder per machine
│   ├── fw-nixos-btw/
│   │   ├── default.nix             # imports + host-specific bits
│   │   └── hardware-configuration.nix
│   ├── homelab-nixos-btw/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── pi/
│       ├── default.nix
│       └── hardware-configuration.nix
│
├── modules/                        # NixOS layer — services, system state
│   ├── core.nix                    # nix settings, locale, users, ssh
│   ├── desktop/
│   │   ├── hyprland.nix
│   │   └── audio.nix
│   ├── apps/
│   │   ├── vscode.nix
│   │   └── treefmt.nix
│   └── server/
│       ├── docker.nix
│       └── wireguard.nix
│
├── home/                           # $HOME layer — Hjem file entries
│   └── javi/
│       ├── common.nix              # zsh, git, tmux — every host
│       ├── desktop.nix             # hyprland.lua, kitty.conf, quickshell
│       └── dotfiles/               # the actual files, verbatim
│           ├── kitty.conf
│           ├── hypr/
│           │   ├── hyprland.lua
│           │   └── keybindings.lua
│           └── zsh/.zshrc
│
└── secrets/
    ├── secrets.nix
    └── wg-private-fw.age