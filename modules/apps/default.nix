{ pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./firefox.nix
    ./git.nix
    ./steam.nix
    ./wireguard.nix
  ];
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # default is wireshark-cli (no GUI)
  };
  environment.systemPackages = with pkgs; [
    # -- Core CLI tools --
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop
    fwupd
    ripgrep # find packages # use rg
    fastfetch
    unzip
    qmk
    jdk25
    python3

    obs-studio
  ];
}
