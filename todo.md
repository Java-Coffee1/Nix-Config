torrenting setup
lastfm 
router
server barmetal


{ ... }: {
  # the namespace (name must be 7 chars or fewer)
  vpnNamespaces.wg = {
    enable = true;
    # normal wg-quick .conf from your VPN provider; keep it out of the nix store
    wireguardConfigFile = "/etc/secrets/wg-vpn.conf";

    # let your LAN reach the web UI
    accessibleFrom = [ "192.168.1.0/24" ];
    portMappings = [ { from = 8080; to = 8080; } ];

    # only if your VPN gives you a forwarded port
    openVPNPorts = [ { port = 51413; protocol = "both"; } ];
  };

  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    torrentingPort = 51413;
  };

  # this puts qbittorrent inside the VPN namespace
  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };
}
