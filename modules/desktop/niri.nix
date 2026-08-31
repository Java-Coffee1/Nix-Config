{ inputs, pkgs, ... }:

{
  ############################################
  ## Niri
  ############################################
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  imports = [
    inputs.noctalia.nixosModules.default
  ];

  programs.noctalia = {
    enable = true;
    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # -- Niri integration --
    zsh
    rofi # look things up
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
  
  home.file.".config/niri".source = ./niri/;
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