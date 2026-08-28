{
  #####################################
  ## Steam
  ############################################
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # if you use Remote Play
    dedicatedServer.openFirewall = true; # if you host game servers
    localNetworkGameTransfers.openFirewall = true; # for LAN game transfers
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # crucial for Steam/games, most are still 32-bit
  };

}