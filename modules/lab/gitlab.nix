{ config, ... }:

{
  age.secrets.gitlab-env.file = ../../secrets/gitlab-env.age;
  systemd.services.gitlab-secrets = {
    before = [ "gitlab-config.service" ];
    requiredBy = [ "gitlab-config.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "gitlab";
      UMask = "0077";
      EnvironmentFile = config.age.secrets.gitlab-env.path;
      RuntimeDirectory = "gitlab-secrets";
      RuntimeDirectoryMode = "0700";
    };
    script = ''
      set -u # stop if a key is missing from the .env
      cd /run/gitlab-secrets
      printf '%s' "$GITLAB_ROOT_PASSWORD" > root-password
      printf '%s' "$GITLAB_SECRET" > secret
      printf '%s' "$GITLAB_OTP" > otp
      printf '%s' "$GITLAB_DB" > db
      printf '%s' "$GITLAB_AR_PRIMARY" > ar-primary
      printf '%s' "$GITLAB_AR_DETERMINISTIC" > ar-deterministic
      printf '%s' "$GITLAB_AR_SALT" > ar-salt
      printf '%s' "$GITLAB_JWS" | base64 -d > jws # base64 so the RSA key fits on one line
    '';
  };

  services.gitlab = {
    enable = true;
    host = "git.jv.ax";
    port = 443;
    https = true; # Traefik handles TLS
    statePath = "/homelab/gitlab";

    # no databasePasswordFile: the db lives on your local Postgres over the unix socket (peer auth)
    initialRootPasswordFile = "/run/gitlab-secrets/root-password";
    secrets = {
      secretFile = "/run/gitlab-secrets/secret";
      otpFile = "/run/gitlab-secrets/otp";
      dbFile = "/run/gitlab-secrets/db";
      jwsFile = "/run/gitlab-secrets/jws";
      activeRecordPrimaryKeyFile = "/run/gitlab-secrets/ar-primary";
      activeRecordDeterministicKeyFile = "/run/gitlab-secrets/ar-deterministic";
      activeRecordSaltFile = "/run/gitlab-secrets/ar-salt";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      gitlab = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8092;
          }
        ];
        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            client_max_body_size 0;
            proxy_read_timeout 300;
          '';
        };
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.gitlab = {
      rule = "Host(`${config.services.gitlab.host}`)";
      entryPoints = [ "https-web" ];
      service = "gitlab";
      tls.certResolver = "letsencrypt";
    };
    services.gitlab.loadBalancer.servers = [ { url = "http://127.0.0.1:8092"; } ];
  };
}
