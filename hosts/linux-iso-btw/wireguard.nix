{ config, ... }:

{
  age.secrets.wg-conf.file = ../../secrets/windscribe-wg.age;
  vpnNamespaces.wg = {
    enable = true;

    wireguardConfigFile = config.age.secrets.wg-conf.path;

    accessibleFrom = [ "10.10.1.170" ];
    portMappings = [
      {
        from = 8012;
        to = 8012;
      }
    ];

    openVPNPorts = [
      {
        port = 51413;
        protocol = "both";
      }
    ];
  };
}
