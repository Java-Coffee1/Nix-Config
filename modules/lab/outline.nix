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
  services.outline = {
    package = unstable.outline;
    enable = true;
    publicUrl = "https://outline.javamurray.com";
    port = 3000;
    forceHttps = false; # Traefik handles TLS
    enableUpdateCheck = false;
    concurrency = 1;

    # your hand-made db, over the unix socket (no password)
    databaseUrl = "postgres://outline@localhost/outline_db?host=/run/postgresql";

    # "local" = module spins up its own redis instance
    redisUrl = "local";

    storage = {
      storageType = "local";
      localRootDir = "/homelab/outline/data";
      uploadMaxSize = 26214400;
    };

    # reuse your OLD keys from the .env or existing data breaks
    secretKeyFile = config.age.secrets.outline-secret-key.path;
    utilsSecretFile = config.age.secrets.outline-utils-secret.path;

    oidcAuthentication = {
      authUrl = "https://auth.javamurray.com/application/o/authorize/";
      tokenUrl = "https://auth.javamurray.com/application/o/token/";
      userinfoUrl = "https://auth.javamurray.com/application/o/userinfo/";
      clientId = "ATN1jxsjVfWCUc1iWejakEB90DWNc0t3PPlRbL4h";
      clientSecretFile = config.age.secrets.outline-oidc-secret.path;
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      usernameClaim = "preferred_username";
      displayName = "Authentik";
    };
  };

  # custom databaseUrl skips the module's local-db setup, so add it back:
  # no SSL over the unix socket, and wait for postgres before starting
  systemd.services.outline = {
    environment.PGSSLMODE = "disable";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  systemd.tmpfiles.rules = [ "d /homelab/outline/data 0750 outline outline -" ];

  age.secrets = {
    outline-secret-key = {
      file = ../../secrets/outline-secret-key.age;
      owner = "outline";
    };
    outline-utils-secret = {
      file = ../../secrets/outline-utils-secret.age;
      owner = "outline";
    };
    outline-oidc-secret = {
      file = ../../secrets/outline-oidc.age;
      owner = "outline";
    };
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      routers.outline = {
        rule = "Host(`outline.javamurray.com`)";
        entryPoints = [ "https-web" ];
        service = "outline";
        tls.certResolver = "letsencrypt";
      };
      services.outline.loadBalancer.servers = [ { url = "http://127.0.0.1:3000"; } ];
    };
  };
}
