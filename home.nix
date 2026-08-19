{ config, pkgs, ... }:

{
  imports = [ ./kde/kde-config.nix ];
  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "25.05";
  home.file."Projects/.keep".text = "";
  programs.git.enable = true;

  home.file.".config/hypr/hyprland.conf".source = ./hyprland/hyprland.conf;

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}
