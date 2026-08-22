# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{

  imports = [
    ./os-config/systemPackages.nix
    ./os-config/programs.nix
    ./hardware-configuration.nix
  ];

  ############################################
  ## Boot
  ############################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  ## Networking
  ############################################

  networking.hostName = "nixos-btw"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  ############################################
  ## Time & Locale
  ############################################

  time.timeZone = "America/Vancouver";

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  ############################################
  ## Desktop Environment
  ############################################
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # needed for non-Wayland-native apps
  };

  # Keep ly, or switch to SDDM/GDM with Wayland support — ly works fine with Hyprland
  services.displayManager.ly.enable = true;

  # Needed for portals (screen share, file pickers, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # swayosd needs its own service for volume/brightness OSD popups
  services.swayosd.enable = true;
  ############################################
  ## Users & Security
  ############################################

  # Define a user account. Don't forget to set a password with `passwd`.
  users.users.javi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable 'sudo' for the user.
    packages = with pkgs; [ tree ];
  };

  security.sudo.wheelNeedsPassword = false;
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan; # Elan(04f3:0c4b) driver
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth = false;
    # kscreenlocker.fprintAuth = true;   # keep it for unlocking the screen
    polkit-1.fprintAuth = true;
  };
  ############################################
  ## Fonts
  ############################################

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  ############################################
  ## Nix Settings
  ############################################

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  virtualisation.docker = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ############################################
  ## Services
  ############################################

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  ############################################
  ## System State Version
  ############################################

  system.stateVersion = "26.05";
}
