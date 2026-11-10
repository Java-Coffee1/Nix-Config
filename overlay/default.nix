{ pkgs, lib, ... }:

{
  ########################
  ## System
  ########################
  system.stateVersion = "26.05";
  javi.isGui = lib.mkDefault false;
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/Vancouver";

  ########################
  ## Nix Settings
  ########################
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

  ########################
  ## Boot
  ########################
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.device = lib.mkDefault "/dev/sda";

  ########################
  ## Networking
  ########################
  services.avahi.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  ############################################
  ## Users & Security
  ############################################
  users.users.javi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "homelab-admin"
    ];
    packages = with pkgs; [ tree ];
  };

  users.users.javi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEtpecmaXPRkULTYaPzCiocRiVmJMxD2p3qCrStGCK5 java@Home-Lab-Live"
  ];

  users.groups.homelab-admin = { };

  security.sudo.wheelNeedsPassword = false;

  ########################
  ## Keyboard
  ########################
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
