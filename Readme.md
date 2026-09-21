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
nixos-rebuild build --flake .#homelab-nixos-btw --target-host javi@10.10.1.170 --sudo
```

## Testing
git add -A
nix flake check

nixos-rebuild dry-build --flake .#nixos-btw

##
update 
nix flake update

then
 nixos-rebuild switch --sudo 