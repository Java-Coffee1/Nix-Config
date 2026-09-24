{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/lab/traefik.nix
    ../../modules/lab/website.nix
    ../../modules/lab/postgress.nix
    ../../modules/lab/authentik.nix
    ../../modules/lab/virtualization/vaultwarden.nix
    ../../modules/lab/outline.nix
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
  services.openssh.settings.PasswordAuthentication = false;

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

  users.users.javi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEtpecmaXPRkULTYaPzCiocRiVmJMxD2p3qCrStGCK5 java@Home-Lab-Live"
  ];
  users.groups.homelab-admin = { };

  users.users.traefik.extraGroups = [ "homelab-admin" ];
  users.users.nginx.extraGroups = [ "homelab-admin" ];

  security.sudo.wheelNeedsPassword = false;

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
    mode = "775";
    #user read/write/delete
    #group read/write/delete
    #everbody else nothing
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/traefik".d = {
    user = "traefik";
    group = "homelab-admin";
    mode = "775";
    #user read/write/delete
    #group read/write/delete
    #everbody else nothing
  };
  systemd.tmpfiles.settings."00-homelab"."/homelab/local-database/".d = {
    user = "root";
    group = "homelab-admin";
    mode = "775";
    #user read/write/delete
    #group read/write/delete
    #everbody else nothing
  };
  systemd.tmpfiles.settings."00-homelab"."/homelab/local-database/postgresql".d = {
    user = "postgres";
    group = "homelab-admin";
    mode = "750";
  };

  fileSystems."/homelab/nfs/data-dumpster" = {
    device = "10.30.30.101:/mnt/DataDumpster/data-dumpster";
    fsType = "nfs";
    options = [ "defaults" ];
  };

}
