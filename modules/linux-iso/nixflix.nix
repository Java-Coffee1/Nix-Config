{ config, ... }:
let
  nfs-media = "/homelab/nfs/linux-isos";
in
{
  # one file per secret, each holding ONLY the raw value (no KEY=value)
  age.secrets = {
    wg-conf.file = ../../secrets/windscribe-wg.age;
    sonarr-api-key.file = ../../secrets/sonarr-api-key.age;
    radarr-api-key.file = ../../secrets/radarr-api-key.age;
    prowlarr-api-key.file = ../../secrets/prowlarr-api-key.age;
  };

  nixflix = {
    enable = true;
    mediaDir = nfs-media;
    downloadsDir = "${nfs-media}/downloads";
    stateDir = "/homelab/nixflix";

    nginx.enable = true;

    vpn = {
      enable = true;
      wgConfFile = config.age.secrets.wg-conf.path;
      allowedIngress = [ "10.10.1.170/32" ];
    };

    downloadarr.qbittorrent = {
      enable = true;
      host = config.vpnNamespaces.wg.namespaceAddress;
      username = "javi";
      password._secret = config.age.secrets.qbittorrent-password.path;
    };

    sonarr = {
      enable = true;
      mediaDirs = [ "${nfs-media}/shows" ]; 
      config.apiKey._secret = config.age.secrets.sonarr-api-key.path;

      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };

    radarr = {
      enable = true;
      config.apiKey._secret = config.age.secrets.radarr-api-key.path;
      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      config.apiKey._secret = config.age.secrets.prowlarr-api-key.path;
      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };
    
  };

  # nixflix doesn't open the peer port for you
  vpnNamespaces.wg.vpn = {
    allowedTCPPorts = [ 51413 ];
    allowedUDPPorts = [ 51413 ];
  };
}
