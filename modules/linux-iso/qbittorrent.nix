{ config, pkgs, ... }:
let
  nfs-data = config.homelab.path;
  profileDir = "${nfs-data.data}/qBittorrent";
  ipFilterFile = "${profileDir}/qBittorrent/ipfilter.dat";
in
{
  services.qbittorrent = {
    enable = true;
    webuiPort = 8012;
    torrentingPort = 51413;

    inherit profileDir;
    serverConfig.Preferences.WebUI = {
      AuthSubnetWhitelistEnabled = true;
      AuthSubnetWhitelist = "10.10.1.170/32";
      ShowExternalIpInStatusBar = true;
    };

    serverConfig.Preferences.IPFilter = {
      Enabled = true;
      File = ipFilterFile;
    };

    serverConfig.BitTorrent = {
      # Don't download files with these extensions, even if they're part of
      # an otherwise-wanted torrent (.scr is the classic exe-disguised-as-a-
      # screensaver malware trick).
      ExcludedFileNamesEnabled = true;
      Session = {
        ExcludedFileNames = "*.exe\n*.scr";
        AnonymousModeEnabled = true;
        # 1 = require encrypted peer connections
        Encryption = 1;
      };
    };
  };

  systemd.services.qbittorrent = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
    wants = [ "qbittorrent-ipfilter-update.service" ];
    after = [ "qbittorrent-ipfilter-update.service" ];
  };

  # Keeps the IP blocklist used by serverConfig.Preferences.IPFilter above
  # fresh. Runs on the host's normal network, not the "wg" namespace -
  # fetching a public blocklist isn't privacy-sensitive.
  systemd.services.qbittorrent-ipfilter-update = {
    description = "Update qBittorrent IP blocklist";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "qbittorrent";
      Group = "qbittorrent";
    };
    script = ''
      ${pkgs.curl}/bin/curl -fsSL https://github.com/Naunter/BT_BlockLists/raw/master/combined.gz \
        | ${pkgs.gzip}/bin/gzip -dc > ${ipFilterFile}.tmp
      mv ${ipFilterFile}.tmp ${ipFilterFile}
    '';
  };

  systemd.timers.qbittorrent-ipfilter-update = {
    description = "Daily update of qBittorrent IP blocklist";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1d";
      Persistent = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8012 ];
}
