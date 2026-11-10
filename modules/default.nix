{ pkgs, ... }:

{
  imports = [
    ./apps/git.nix
    ./apps/neovim.nix
  ];
  environment.systemPackages = with pkgs; [
    wget
    curl
    htop

    ripgrep # find packages # use rg
    fastfetch
    unzip
    busybox
    python3
    dig
    tmux
    btop

    cargo
    rustc
    rust-analyzer # LSP for neovim
    clippy # linter
    rustfmt # formatter
  ];
}
