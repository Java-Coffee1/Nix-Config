{ ... }: {
  imports = [
    ../../overlay
    ../../modules/default.nix
    ./hardware-configuration.nix
        ../../modules/apps/git.nix


    ##Scripts
    ../../lazy-scripts/default.nix

    # Services
    ../../modules/lab/traefik.nix
    ../../modules/lab/website.nix
    ../../modules/lab/postgress.nix
    ../../modules/lab/authentik.nix
    ../../modules/lab/virtualization/vaultwarden.nix
    ../../modules/lab/outline.nix
    ../../modules/lab/jellyfin.nix
    ../../modules/lab/copyparty.nix
    ../../modules/lab/immich.nix
    ../../modules/lab/virtualization/dumdo.nix
    ../../modules/lab/email-server.nix
    ../../modules/lab/granfana.nix
    ../../modules/lab/navidrome.nix
  ];

  #######################
  ## System
  ########################
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # allow emulation for devicesz

  ########################
  ## Boot
  ########################
  boot.loader.grub.useOSProber = true;

  ########################
  ## Networking
  ########################
  networking.networkmanager.enable = true;

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
  users.users.javi.extraGroups = [ "networkmanager" ];

  users.users.javi.openssh.authorizedKeys.keys = [
    "AAAAB3NzaC1yc2EAAAADAQABAAABgQCNZZVhA1VenxOFIIu9FffKhP9VhliKVxS/P0Z6OjU4X3gb6qHXia0SIwBW2bge0uJXynvgZvjEYpziG2wbpBjqimUCQB5DCzL5eQlTyLrhMIhnUz9yblG2b10pS6TgJSgUkIDytHAVtUxjYj/KJMcBZSu/EtmPGuhbFjCK7wagtLutu/P6uGuq7kqreOIy3fK6q4SEej5//xqxjuPBpULKkTtJyOYs/VsNjN2xNp4mt69+Q0RE2P+9jNJjtPtrZtMa5jtGNH7hAiNeeeb8gA3HvTrpuX/LENrG2/FPCGv7gamLW5Bxjb1mZncLKukzuceIma69KndSM+GZMJC4Z0QSQ6yPq6NCLA0RCf0fQM/Xi8BS8Z79SGSrQdDLUXMDAFkSEHiOvIsfQ2LucoXo6EEb9p56KUhxgXIRS6aFpo6oXFub2GleyqTPL04Q8BzgeiHCBeBN6ITCrAfwz45qJ9jt9vxvdvhbsMimmrIOilmoGsXgC4hBjJY8kjmj06vA880= root@truenas"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ+MKzP6XyJfJ/UX/lLkgxuVdF/lBZw2Pynhyn8pBnP ipadsshkey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxWxbeAk3VSguxZl9MzZ93ztk3SgwlRKs94TzE6Cjzm iPhonekey"
  ];

  users.users.traefik.extraGroups = [ "homelab-admin" ];
  users.users.nginx.extraGroups = [ "homelab-admin" ];

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
  systemd.tmpfiles.settings."00-homelab"."/homelab/jellyfin".d = {
    user = "jellyfin";
    group = "homelab-admin";
    mode = "750";
  };
  systemd.tmpfiles.settings."00-homelab"."/homelab/hundred-hues".d = {
    user = "hundred-hues";
    group = "homelab-admin";
    mode = "750";
  };

  fileSystems."/homelab/nfs/data-dumpster" = {
    device = "10.30.30.101:/mnt/DataDumpster/data-dumpster";
    fsType = "nfs";
    options = [ "defaults" ];
  };

  fileSystems."/homelab/nfs/linux-isos" = {
    device = "10.30.30.101:/mnt/DataDumpster/Linux_Isos";
    fsType = "nfs";
    options = [ "defaults" ];
  };

}
