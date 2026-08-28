{ pkgs, ... }:

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
    # -- Hyprland integration --
    awww # desktop background
    zsh
    rofi # look things up
    waybar # task bar
    swaynotificationcenter # notification daemon
    pipewire # audio driver
    wireplumber # audio driver

    kdePackages.dolphin

    kitty
    playerctl
    swayosd
    cliphist
    wl-clipboard
    grim
    slurp

    papirus-icon-theme        # or colloid-icon-theme — vinceliuice, pairs with Orchis
    adwaita-icon-theme        # fallback for icons the main theme lacks
    hicolor-icon-theme

    quickshell #ui stuff

  ];
  # qt = {
  #   enable = true;
  #   platformTheme = "qt5ct";   # installs qt5ct AND qt6ct, sets QT_QPA_PLATFORMTHEME
  #   style = "kvantum";         # installs qt5 + qt6 kvantum plugins, sets QT_STYLE_OVERRIDE
  # };
  # environment.etc."xdg/kdeglobals".text = ''
  #   [Icons]
  #   Theme=Papirus-Dark
  # '';

}