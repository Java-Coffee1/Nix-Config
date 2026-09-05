{ pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./firefox.nix
    ./git.nix
    ./steam.nix
    ./wireguard.nix
  ];
  environment.systemPackages = with pkgs; [
    # -- Core CLI tools --
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop
    fwupd
    ripgrep # find packages
    fastfetch
    unzip
    qmk

    obs-studio
  ];
}
