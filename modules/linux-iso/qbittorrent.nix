{ ... }: {
  services.qbittorrent = {
    enable = true;
    webuiPort = 8012;
    torrentingPort = 51413;

    serverConfig.Preferences.WebUI = {
      AuthSubnetWhitelistEnabled = true;
      AuthSubnetWhitelist = "10.10.1.170/32";
    };
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  networking.firewall.allowedTCPPorts = [ 8012 ];
}
