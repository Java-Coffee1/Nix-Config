{...}:

{
  imports = [
    ../../overlay
    ./hardware-configuration.nix
    ../../modules/default.nix
    ../../modules/apps/git.nix

  ];

  ###########################
  ## Networking 
  ###########################

  networking = {
    useDHCP = false;
    interfaces.ens18 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.10.1.180";
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

  ############################################
  ## Users & Security
  ############################################
  users.users.javi.extraGroups = [ "networkmanager" ];

  users.users.javi.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ2c0GzlVMjV06CS7bWbCaAbzG2+7g5FCg/vClJPe0C" # shel laptop
    "AAAAB3NzaC1yc2EAAAADAQABAAABgQCNZZVhA1VenxOFIIu9FffKhP9VhliKVxS/P0Z6OjU4X3gb6qHXia0SIwBW2bge0uJXynvgZvjEYpziG2wbpBjqimUCQB5DCzL5eQlTyLrhMIhnUz9yblG2b10pS6TgJSgUkIDytHAVtUxjYj/KJMcBZSu/EtmPGuhbFjCK7wagtLutu/P6uGuq7kqreOIy3fK6q4SEej5//xqxjuPBpULKkTtJyOYs/VsNjN2xNp4mt69+Q0RE2P+9jNJjtPtrZtMa5jtGNH7hAiNeeeb8gA3HvTrpuX/LENrG2/FPCGv7gamLW5Bxjb1mZncLKukzuceIma69KndSM+GZMJC4Z0QSQ6yPq6NCLA0RCf0fQM/Xi8BS8Z79SGSrQdDLUXMDAFkSEHiOvIsfQ2LucoXo6EEb9p56KUhxgXIRS6aFpo6oXFub2GleyqTPL04Q8BzgeiHCBeBN6ITCrAfwz45qJ9jt9vxvdvhbsMimmrIOilmoGsXgC4hBjJY8kjmj06vA880= root@truenas"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ+MKzP6XyJfJ/UX/lLkgxuVdF/lBZw2Pynhyn8pBnP ipadsshkey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxWxbeAk3VSguxZl9MzZ93ztk3SgwlRKs94TzE6Cjzm iPhonekey"

  ];


  ###########################################
  ## Raid Setup
  ###########################################
  
}