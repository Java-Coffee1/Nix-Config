{ ... }:

{
  imports = [
    ../../overlay
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/apps/git.nix

    ../../modules/email/salwart.nix
    ../../modules/email/bulwark.nix
    ../../lazy-scripts/email/default.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; # "nodev" is used for UEFI
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  ###########################
  ## Networking
  ###########################

  networking = {
    useDHCP = false;
    interfaces.enp5s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "23.130.212.203";
          prefixLength = 28;
        }
      ];
    };
    defaultGateway = "23.130.212.194";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  users.users.javi.openssh.authorizedKeys.keys = [
    "AAAAB3NzaC1yc2EAAAADAQABAAABgQCNZZVhA1VenxOFIIu9FffKhP9VhliKVxS/P0Z6OjU4X3gb6qHXia0SIwBW2bge0uJXynvgZvjEYpziG2wbpBjqimUCQB5DCzL5eQlTyLrhMIhnUz9yblG2b10pS6TgJSgUkIDytHAVtUxjYj/KJMcBZSu/EtmPGuhbFjCK7wagtLutu/P6uGuq7kqreOIy3fK6q4SEej5//xqxjuPBpULKkTtJyOYs/VsNjN2xNp4mt69+Q0RE2P+9jNJjtPtrZtMa5jtGNH7hAiNeeeb8gA3HvTrpuX/LENrG2/FPCGv7gamLW5Bxjb1mZncLKukzuceIma69KndSM+GZMJC4Z0QSQ6yPq6NCLA0RCf0fQM/Xi8BS8Z79SGSrQdDLUXMDAFkSEHiOvIsfQ2LucoXo6EEb9p56KUhxgXIRS6aFpo6oXFub2GleyqTPL04Q8BzgeiHCBeBN6ITCrAfwz45qJ9jt9vxvdvhbsMimmrIOilmoGsXgC4hBjJY8kjmj06vA880= root@truenas"
    "assh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/mqwjzWT4o4ARZjX6uvcQa2iynZEIar8uFs3JSsNXK javi@code-nixos-btw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ+MKzP6XyJfJ/UX/lLkgxuVdF/lBZw2Pynhyn8pBnP ipadsshkey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxWxbeAk3VSguxZl9MzZ93ztk3SgwlRKs94TzE6Cjzm iPhonekey"
  ];

}
