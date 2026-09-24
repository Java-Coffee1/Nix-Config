{ pkgs, ... }:

{
  imports = [
    ./apps/git.nix
    ../lazy-scripts/default.nix
  ];
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop

    ripgrep # find packages # use rg
    fastfetch
    unzip
    busybox
    python3
  ];
}
