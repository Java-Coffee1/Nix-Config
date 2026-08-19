{ config, pkgs, ... }:

{
  imports = [ ./kde/kde-config.nix ];
  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "25.05";
  home.file."Projects/.keep".text = "";
  programs.git.enable = true;

  home.file.".config/hypr/hyprland.lua".source = ./hyprland/hyprland.lua;
  home.file.".config/hypr/keybindings.lua".source = ./hyprland/keybindings.lua;
  home.file.".config/hypr/var.lua".source = ./hyprland/var.lua;


  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}
