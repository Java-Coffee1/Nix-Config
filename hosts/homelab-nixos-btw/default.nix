{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/lab/traefik.nix

  ];

  #######################
  ## System
  ########################

  javi.isGui = false;
  system.stateVersion = "26.05";
  time.timeZone = "America/Vancovuer";

  ############################################
  ## Nix Settings
  ############################################

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nixpkgs.config.allowUnfree = true;

  ########################
  ## Boot
  ########################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ########################
  ## Networking
  ########################
  networking.networkmanager.enable = true;

  services.avahi.enable = true;

  services.openssh.enable = true;

  networking = {
    useDHCP = false; # Disable global DHCP
    interfaces.ens18 = {
      useDHCP = false; # Disable DHCP on this specific interface
      ipv4.addresses = [
        {
          address = "10.10.1.170"; # Your desired static IP
          prefixLength = 24; # Subnet mask (24 = 255.255.255.0)
        }
      ];
    };

    defaultGateway = "10.10.1.1"; # Your router's IP address

    nameservers = [
      "10.1.2.10"
      "1.1.1.1"
      "8.8.8.8"
    ]; # DNS servers
  };

  ############################################
  ## Users & Security
  ############################################

  # Define a user account. Don't forget to set a password with `passwd`.
  users.users.javi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ]; # Enable 'sudo' for the user.
    packages = with pkgs; [ tree ];
  };
  security.sudo.wheelNeedsPassword = false;

  users.users.javi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
  ];

  ########################
  ## Keyboard
  ########################
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ############################################
  ## Apps & Virtualisation
  ############################################
  virtualisation.docker = {
    enable = true;
  };
  ############################################
  ## Storage
  ############################################
  systemd.tmpfiles.rules = [
    "d /homelab 0755 root javi -"
    "d /homelab/traefik 0750 traefik traefik -"
  ];
}
