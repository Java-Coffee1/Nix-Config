{ config, ... }:
let
  nfs-data = config.homelab.path;
in

{
  age.secrets.radarr-env.file = ../../secrets/servarr-env.age;
  services.radarr = {
    enable = true;
    openFirewall = true; # on port 7878
    dataDir = "${nfs-data.data}/radarr";

    settings.auth = {
      method = "Forms";
      required = "DisabledForLocalAddresses";
    };

    environmentFiles = [
      config.age.secrets.radarr-env.path
    ];
  };
}
