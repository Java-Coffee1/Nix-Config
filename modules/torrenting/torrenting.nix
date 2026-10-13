{ ... }:

{
  services.qbittorrent = {
    enable = true;
    webuiPort = 4032;
    profileDir = "/linux-isos-data/qbittorrent";
    serverConfig = {
      BitTorrent.Session.DefaultSavePath = "/linux-isos-data/qbittorrent";
    };
  };
}
