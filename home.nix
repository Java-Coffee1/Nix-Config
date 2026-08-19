{ config, pkgs, ... }:

{
  imports = [ ./kde/kde-config.nix ];
  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "25.05";
  home.file."Projects/.keep".text = "";
  programs.git.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
  home.file.".hyprland".source = /home/javi/.config/hypr";

}
