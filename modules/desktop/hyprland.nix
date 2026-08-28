{pkgs, ...}:

{
  ############################################
  ## Hyprland
  ############################################
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };  

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
  home.file.".config/rofi/colors.rasi".source = ./hyprland/rofi/colors.rasi;
  home.file.".config/rofi/fonts.rasi".source = ./hyprland/rofi/fonts.rasi;
  home.file.".config/rofi/onedark.rasi".source = ./hyprland/rofi/onedark.rasi;

  ## waybar
  home.file.".config/waybar/config.jsonc".source = ./hyprland/waybar/config.jsonc;
  home.file.".config/waybar/style.css".source = ./hyprland/waybar/style.css;
  home.file.".config/waybar/onedark.css".source = ./hyprland/waybar/onedark.css;

  # Kvantum
  home.file.".config/Kvantum/kvantum.kvconfig".source = ./hyprland/kvantum/kvantum.kvconfig;
  home.file.".config/Kvantum/Orchis".source = ./hyprland/kvantum/Orchis;
  ## widget config files 
  # home.file.".config/ags/config.js".source = ./hyprland/ags/config.js;


  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;   # or adwaita-icon-theme, capitaine-cursors, etc.
    name = "Bibata-Modern-Classic";
    size = 24;
  };  
  

  environment.systemPackages = with pkgs; [
    # -- Hyperland intergration --
     # destop background
    zsh
    rofi #look things up 
    waybar # task bar 
    swaynotificationcenter # Notification Daemom
    pipewire #audio Driver
    wireplumber #audio Driver

    kdePackages.dolphin


    kitty
    playerctl
    swayosd
    cliphist
    wl-clipboard
    grim 
    slurp  
    

    ## -- hyperland styling 
    kdePackages.qt6ct
    libsForQt5.qt5ct

    libsForQt5.qtstyleplugin-kvantum   # Qt5 apps
    qt6Packages.qtstyleplugin-kvantum  # Qt6 apps (Plasma 6 is Qt6-based)
  ];

}