############################################
## System Packages
############################################

# List packages installed in system profile.
# You can use https://search.nixos.org/ to find more packages (and options).
{ pkgs, ... }:

{
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    # -- Core CLI tools --
    vim # Do not forget to add an editor to edit configuration.nix! Nano is also installed by default.
    wget
    curl
    htop
    fwupd
    ripgrep # find packages # use rg
    fastfetch
    unzip
    qmk
    jdk25
    python3
    busybox

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
  ];
}
