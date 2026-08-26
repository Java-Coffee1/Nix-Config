{ config, pkgs, ... }:
{
  imports = [ ./kde/kde-config.nix ];

  home.username = "javi";
  home.homeDirectory = "/home/javi";
  home.stateVersion = "25.05";

  home.file."Projects/.keep".text = "";
  programs.git.enable = true;

  ## Hyprland configuration files
  home.file.".config/hypr/hyprland.lua".source = ./hyprland/hyprland.lua;
  home.file.".config/hypr/keybindings.lua".source = ./hyprland/keybindings.lua;
  home.file.".config/hypr/var.lua".source = ./hyprland/var.lua;
  home.file.".config/hypr/windows_and_workspaces.lua".source = ./hyprland/windows_and_workspaces.lua;

  ## rofi configuration files
  home.file.".config/rofi/config.rasi".source = ./hyprland/rofi/config.rasi;

  ## Qt app styling (Dolphin, Kate, Konsole, etc.)
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  home.file.".config/Kvantum/Orchis".source = ./hyprland/qt-style/Kvantum/Orchis;
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=OrchisDark
  '';
  home.file.".config/color-schemes/OrchisDark.colors".source = ./hyprland/qt-style/color-schemes/OrchisDark.colors;
  home.file.".config/kdeglobals".text = ''
    [Icons]
    Theme=Tela-circle-dark

    [General]
    ColorScheme=OrchisDark
  '';

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}