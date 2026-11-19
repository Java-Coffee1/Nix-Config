{ config, pkgs, ... }:
let
  nfs-data = config.homelab.path;
  profileDir = "${nfs-data.data}/qBittorrent";
  ipFilterFile = "${profileDir}/qBittorrent/ipfilter.dat";
  defaultSavePath = "${config.nixflix.downloadsDir}/default";
in
{
  age.secrets.qbittorrent-password.file = ../../secrets/linux-iso-btw/qbittorrent-password.age;

  services.qbittorrent = {
    enable = true;
    webuiPort = 8012;
    torrentingPort = 51413;

    inherit profileDir;
    serverConfig.Preferences.WebUI = {
      AuthSubnetWhitelistEnabled = true;
      AuthSubnetWhitelist = "10.10.1.170/32";
      ShowExternalIpInStatusBar = true;
      Username = "javi";
      Password_PBKDF2 = "@ByteArray(PUnvoYY0kvwuj4Z95Tzf8Q==:3ocgdUvjllp/FTCtTDBn1QJuIZLEp4hMs+J+qe+9r9Z1rAmHiiLYglMMnhg0EMu5RSFIhxL8fvEeHhEDROkLew==)";
    };

    serverConfig.Preferences.IPFilter = {
      Enabled = true;
      File = ipFilterFile;
    };

    serverConfig.BitTorrent = {
      ExcludedFileNamesEnabled = true;
      Session = {
        DefaultSavePath = defaultSavePath;
        ExcludedFileNames = "*.exe\n*.scr";
        AnonymousModeEnabled = true;
        # 1 = require encrypted peer connections
        Encryption = 1;

        # qBittorrent's own defaults (3 active downloads, 5 active torrents
        # total) were queuing requests behind each other - bump the cap so
        # more of what Radarr/Sonarr/Lidarr grab can actually run at once.
        QueueingSystemEnabled = true;
        MaxActiveDownloads = 50;
        MaxActiveUploads = 25;
        MaxActiveTorrents = 75;
      };
    };
  };

  systemd.services.qbittorrent = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
    wants = [ "qbittorrent-ipfilter-update.service" ];
    requires = [ "qbittorrent-savepath-setup.service" ];
    after = [
      "qbittorrent-ipfilter-update.service"
      "qbittorrent-savepath-setup.service"
    ];
  };

  systemd.services.qbittorrent-savepath-setup = {
    description = "Create qBittorrent's default download directory on the NFS media share";
    unitConfig.RequiresMountsFor = [ config.nixflix.downloadsDir ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/install -d -m 0775 -o qbittorrent -g media ${defaultSavePath}";
    };
  };

  vpnNamespaces.wg.portMappings = [
    {
      from = 8012;
      to = 8012;
    }
  ];
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
      ${pkgs.curl}/bin/curl -fsSL https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz \
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
