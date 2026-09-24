{ pkgs, inputs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ./wireguard.nix
    ../../modules/default.nix
    ../../modules/fw-modules.nix
    inputs.noctalia.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
  ];

  ############################################
  ## System
  ############################################

  system.stateVersion = "26.05";

  javi.isGui = true;

  time.timeZone = "America/Vancouver";

  ############################################
  ## Nix Settings
  ############################################

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/user/my-nixos-config"; # sets NH_OS_FLAKE variable for you
  };

  ############################################
  ## Boot & Kernel
  ############################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;

  ############################################
  ## Framework 16 Hardware
  ############################################

  hardware.enableAllFirmware = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  ############################################
  ## Networking
  ############################################

  networking.networkmanager.enable = true;

  services.avahi.enable = true;

  services.openssh.enable = true;

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
      "wireshark"
    ]; # Enable 'sudo' for the user.
    packages = with pkgs; [ tree ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Fingerprint reader disabled
  services.fprintd.enable = false;
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth = false;
  };

  services.gnome.gnome-keyring.enable = true;

  ############################################
  ## Desktop Environment
  ############################################

  services.displayManager.ly.enable = true;

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

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

  # Needed for portals (screen share, file pickers, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  programs.zsh.enable = true;
  users.users.javi.shell = pkgs.zsh;

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = { };
    };
  };
  ############################################
  ## Audio
  ############################################

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

  ############################################
  ## Apps & Virtualisation
  ############################################

  environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  virtualisation.docker = {
    enable = true;
  };
  services.flatpak.enable = true;
}
