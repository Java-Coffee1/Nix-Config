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

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
    };
    iconTheme = {
      name = "Tela-circle"; # Pairs excellently with Orchis
      package = pkgs.tela-circle-icon-theme;
    };
  };

  # Kvantum
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;   # or adwaita-icon-theme, capitaine-cursors, etc.
    name = "Bibata-Modern-Classic";
    size = 24;
  };  
    
}