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

    adwaita-qt

    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
  ];
  nixpkgs.config.qt5 = {
    enable = true;
    platformTheme = "qt5ct"; 
      style = {
        package = pkgs.utterly-nord-plasma;
        name = "Utterly Nord Plasma";
      };
  };

}