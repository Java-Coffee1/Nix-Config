{ inputs, config, pkgs, ... }:

{
  # imports = [ ./kde/kde-config.nix ];
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
  home.file.".config/hypr/wallpaper1.png".source = ./hyprland/wallpaper/wallpaper1.png;

  home.file.".config/kitty/kitty.conf".source = ./hyprland/kitty/kitty.conf;
  wayland.windowManager.hyprland.systemd.enable = false;

  # swayosd needs its own service for volume/brightness OSD popups
  services.swayosd.enable = true;

  ## rofi configuration files
  home.file.".config/rofi/config.rasi".source = ./hyprland/rofi/config.rasi;
  home.file.".config/rofi/theme.rasi".source = ./hyprland/rofi/theme.rasi;

  ## widget config files 
  # home.file.".config/ags/config.js".source = ./hyprland/ags/config.js;


  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
    };
  };
}
