{ pkgs, config, ... }:

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
}
