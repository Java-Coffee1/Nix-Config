{
  config,
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  services.immich.package = unstable.immich;
  services.immich.enable = true;
  # immich-server and immich-machine-learning both run in system-immich.slice;
  # raise its share so it wins CPU/IO contention against the other lab services.
  systemd.slices.system-immich.sliceConfig = {
    CPUWeight = 400;
    IOWeight = 400;
  };
  services.immich.port = 2283;
  services.immich.host = "127.0.0.1";
  services.immich.environment.IMMICH_LOG_LEVEL = "warn";
  services.redis.servers.immich.logLevel = "warning";
  systemd.services.immich-server.unitConfig.RequiresMountsFor = [
    "/homelab/nfs/data-dumpster/immich"
  ];
  services.immich.mediaLocation = "/homelab/nfs/data-dumpster/immich";

  services.immich.database = {
    enable = true;
    createDB = true;
    name = "immich";
    user = "immich";
    host = "/run/postgresql";
    port = 5432;
  };
  services.postgresql.ensureDatabases = [ "immich" ];
  services.postgresql.ensureUsers = [
    {
      name = "immich";
      ensureDBOwnership = true;
      ensureClauses.login = true;
      ensureClauses.superuser = true;
    }
  ];
  services.traefik.dynamicConfigOptions.http = {
    routers.immich = {
      rule = "Host(`photos.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "immich";
      middlewares = [ "immich-upload" ];
      tls.certResolver = "letsencrypt";
    };
    routers.immich-old = {
      rule = "Host(`photos.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "immich";
      middlewares = [ "immich-redirect" ];
      tls.certResolver = "letsencrypt";
    };
    middlewares.immich-redirect.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://photos.jv.ax/\${1}";
      permanent = true;
    };
    services.immich.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.services.immich.port}"; }
    ];
  };
}
