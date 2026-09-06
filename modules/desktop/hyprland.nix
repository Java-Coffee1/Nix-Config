{ inputs, pkgs, ... }:

{
  imports = [ inputs.noctalia.nixosModules.default ];

  ############################################
  ## Hyprland
  ############################################
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };

  programs.noctalia = {
    enable = true;
    # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
    recommendedServices.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # -- Hyprland integration --
    zsh
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

    crosspipe
    satty

    papirus-icon-theme # or colloid-icon-theme — vinceliuice, pairs with Orchis
    adwaita-icon-theme # fallback for icons the main theme lacks
    hicolor-icon-theme

    alacritty
  ];

  ############################################
  ## Audio
  ############################################
  services.avahi.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    raopOpenFirewall = true;

    extraConfig.pipewire."10-airplay" = {
      "context.modules" = [
        {
          name = "libpipewire-module-raop-discover";

          # increase the buffer size if you get dropouts/glitches
          # args = {
          #   "raop.latency.ms" = 500;
          # };
        }
      ];
    };
  };
}
