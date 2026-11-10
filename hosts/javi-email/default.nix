{ ... }:

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
}
