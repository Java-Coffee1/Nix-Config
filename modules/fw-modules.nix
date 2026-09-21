{ pkgs, ... }:

{
  imports = [
    ./apps/firefox.nix
    ./steam.nix
    ./vs-code.nix
  ]
  environment.systemPackages = with pkgs; [
    fwupd
    # -- Core CLI tools --
    qmk
    jdk25
    python3
  
    obs-studio

    # -- Communication --
    element-desktop
    (pkgs.discord.override { withOpenASAR = true; })
    slack
    teams-for-linux

    # -- Games --
    # modrinth-app
    lunar-client

    # -- Media / Audio --
    ytmdesktop
    easyeffects
    orca-slicer
    reaper
    # docker

    # -- Hyprland integration --
    zsh
    pipewire # audio driver
    wireplumber # audio driver

    kdePackages.dolphin
    kdePackages.gwenview
    kdePackages.kimageformats # avif, heif, psd, xcf, jxl...
    qt6.qtimageformats # webp, tiff, and friends

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

    # -- fonts --
    nerd-fonts.geist-mono
    # -- icons --
    tela-circle-icon-theme
  ];
}