{ inputs, config, pkgs, ... }:

{
  imports = [ ./desktop/hyprland-home.nix ];
  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "26.05";
  home.file."Projects/.keep".text = "";

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };


  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;   # or adwaita-icon-theme, capitaine-cursors, etc.
    name = "Bibata-Modern-Classic";
    size = 24;
  };  
    
}