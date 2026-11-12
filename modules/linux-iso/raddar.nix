{ config, ... }:
let
  nfs-data = config.homelab.path;
in

{
  age.secrets.radarr-env.file = ../../secretes/servarr-env.age;
  services.radarr = {
    enable = true;
    openFirewall = true; # on port 7878
    dataDir = "${nfs-data.data}/radarr";

    environmentFiles = [ 
      config.radarr-env.path
    ];
  };
}
