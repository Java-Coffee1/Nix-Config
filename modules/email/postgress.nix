{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    identMap = ''
      postgres root postgres
    '';
    initdbArgs = [ "--data-checksums" ];
    enableTCPIP = false;
    # settings.port = 5432;
    dataDir = "/homelab/local-database/postgresql";
    settings = {
      timezone = "America/Vancouver";
      log_timezone = "America/Vancouver";
    };
  };

  config.service.postgresql = {
    enable = true;
    ensureDatabases = [ "mail-data" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser auth-method
      local all      all    trust
    '';
  };
}
