{ pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./firefox.nix
    ./git.nix
    ./steam.nix
    ./wireguard.nix
  ];
}
