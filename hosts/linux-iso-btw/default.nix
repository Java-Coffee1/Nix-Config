{ ... }:

{
  imports = [
    ../../overlay
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/apps/git.nix

    ../../modules/linux-iso/qbittorrent.nix

    ./wireguard.nix
  ];

  ##########################
  ## Boot
  ##########################
  boot.loader.grub.useOSProber = true;

  ###########################
  ## Networking
  ###########################

  networking.networkmanager.enable = true;

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
  users.users.javi.extraGroups = [ "networkmanager" ];

  ##########################
  ## Storage
  ##########################
  systemd.tmpfiles.settings."00-linux-iso"."/linux-isos-data".d = {
    user = "root";
    group = "homelab-admin";
    mode = "755";
  };

  fileSystems."/linux-isos-data/linux-isos" = {
    device = "10.30.30.101:/mnt/DataDumpster/Linux_Isos";
    fsType = "nfs";
    options = [ "defaults" ];
  };
}
