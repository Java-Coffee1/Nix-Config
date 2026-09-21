{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/javi.nix
  ];
  javi.isGui = false;
  system.stateVersion = "26.05";
}
