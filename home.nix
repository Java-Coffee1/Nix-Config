{ config, pkgs, ... }:

{
  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "25.05";

  programs.git.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}
