{ pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/default.nix
  ];

  ##########################
  ## System
  ##########################

  javi.isGui = false;
  system.stateVersion = "26.05";
  time.timeZone = "America/Vancouver";

  ##########################
  ## Nix Settings
  ##########################

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"

  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true; 
    clean.extraArgs = "--keep-since 4d --keep 7";
  };
  ##########################
  ## Boot 
  ##########################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ###########################
  ## Networking
  ###########################

  networking.networkmanager.enable = true;
  services.avahi.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking = {
    useDHCP = false;
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.10.1.105";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "10.10.1.1";

    nameservers = [
      "10.1.2.10"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  ###########################
  ## Users & Security
  ###########################

  users.users.javi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "homelab-admin"
    ];
    packages = with pkgs; [ tree];
  };

  users.users.javi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEtpecmaXPRkULTYaPzCiocRiVmJMxD2p3qCrStGCK5 java@Home-Lab-Live"
  ];

  users.groups.homelab-admin = { };

  security.sudo.wheelNeedsPassword = false;

  ##########################
  ## Keyboard
  ##########################

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}