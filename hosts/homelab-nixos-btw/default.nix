{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/lab/traefik.nix
    ../../modules/lab/website.nix
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
      "homelab-admin"
    ]; # Enable 'sudo' for the user.
    packages = with pkgs; [ tree ];
  };

  users.groups.homelab-admin = { };
  
  users.users.traefik.extraGroups = [ "homelab-admin" ];
  users.users.nginx.extraGroups = [ "homelab-admin" ];

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
  systemd.tmpfiles.settings."00-homelab"."/homelab".d = {
    user = "root";
    group = "homelab-admin";
    mode = "770";
    #user read/write/delete
    #group read/write/delete
    #everbody else nothing
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/traefik".d = {
    user = "traefik";
    group = "homelab-admin";
    mode = "770";
    #user read/write/delete
    #group read/write/delete
    #everbody else nothing
  };
}
