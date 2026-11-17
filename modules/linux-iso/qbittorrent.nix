{ config, pkgs, ... }:
let
  nfs-data = config.homelab.path;
  profileDir = "${nfs-data.data}/qBittorrent";
  ipFilterFile = "${profileDir}/qBittorrent/ipfilter.dat";
in
{
  # raw value only (no KEY=value) - the plaintext login password, used by
  # nixflix.downloadarr to register this qBittorrent with sonarr/radarr/prowlarr
  age.secrets.qbittorrent-password.file = ../../secrets/qbittorrent-password.age;

  services.qbittorrent = {
    enable = true;
    webuiPort = 8012;
    torrentingPort = 51413;

    inherit profileDir;
    serverConfig.Preferences.WebUI = {
      AuthSubnetWhitelistEnabled = true;
      AuthSubnetWhitelist = "10.10.1.170/32";
      ShowExternalIpInStatusBar = true;

      # local login for nixflix's downloadarr integration (sonarr/radarr talk to
      # qBittorrent's API from the VPN bridge, which AuthSubnetWhitelist above
      # doesn't cover). Password matches secrets/qbittorrent-password.age.
      Username = "javi";
      Password_PBKDF2 = "@ByteArray(PUnvoYY0kvwuj4Z95Tzf8Q==:3ocgdUvjllp/FTCtTDBn1QJuIZLEp4hMs+J+qe+9r9Z1rAmHiiLYglMMnhg0EMu5RSFIhxL8fvEeHhEDROkLew==)";
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

  # Lets the WebUI be reached at vpnNamespaces.wg.namespaceAddress:8012 from
  # the default netns (where sonarr/radarr/the downloadarr integration run) -
  # the "wg" netns firewall drops everything by default otherwise.
  vpnNamespaces.wg.portMappings = [
    {
      from = 8012;
      to = 8012;
    }
  ];

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
