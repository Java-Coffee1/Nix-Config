{ config, pkgs, ... }:

let
  unstableTarball = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
in
{
  nixpkgs.config = {
    packageOverrides = pkgs: { unstable = import unstableTarball { config = config.nixpkgs.config; }; };
  };
  services.immich.package = pkgs.unstable.immich;
  services.immich.enable = true;
  services.immich.port = 2283;
  services.immich.host = "127.0.0.1";
  services.immich.environment.IMMICH_LOG_LEVEL = "warn";
  services.redis.servers.immich.logLevel = "warning";
  services.immich.mediaLocation = "/homelab/nfs/data-dumpster/immich/user-data";

  services.traefik.dynamicConfigOptions.http = {
    routers.immich = {
      rule = "Host(`photos.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "immich";
      tls.certResolver = "letsencrypt";
    };
    services.immich.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.services.immich.port}"; }
    ];
  };
}
