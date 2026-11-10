{ ...}:

{
  imports = [
    ../../overlay
    ../../modules/default.nix
    ./hardware-configuration.nix  

    ../../modules/code-nixos-btw/claude.nix
    ../../modules/code-nixos-btw/llama.nix
    ../../modules/code-nixos-btw/pi.nix

    
  ];

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
          address = "10.10.1.180"; # Your desired static IP
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

  ############################################
  ## Dotfiles (this host only)
  ############################################
  hjem.users.javi.files.".tmux.conf".text = ''
    set -g extended-keys on
  '';

  programs.git.enable = true;
  programs.git.config = {
    user.name = "bot-javi";
    user.email = "bot-javi@jv.ax";
  };
}