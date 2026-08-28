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
  environment.systemPackages = with pkgs; [
    # -- Hyperland intergration --
    awww # destop background
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