{ inputs, config, ... }:

{
  age.secrets.authentik-env.file = ../../secrets/authentik-env.age;
  age.secrets.authentik-ldap-env.file = ../../secrets/authentik-ldap-env.age;
  imports = [ inputs.authentiknix.nixosModules.default ];
  services.authentik = {
    enable = true;
    createDatabase = false;
    # The environmentFile needs to be on the target host!
    # Best use something like sops-nix or agenix to manage it
    environmentFile = config.age.secrets.authentik-env.path;
    settings = {
      postgresql = {
        host = "/run/postgresql";
        name = "authentik_db";
        user = "authentik";
      };
      email = {
        host = "10.10.1.150";
        port = 2500;
        username = "noreply@javamurray.com";
        use_tls = true;
        use_ssl = false;
        from = "noreply@javamurray.com";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
  services.authentik-ldap = {
    enable = true;
    environmentFile = config.age.secrets.authentik-ldap-env.path;
  };
  services.traefik.dynamicConfigOptions = {
    http = {
      routers.authentik = {
        rule = "Host(`auth.javamurray.com`)";
        entryPoints = [ "https-web" ];
        service = "authentik";
        tls.certResolver = "letsencrypt";
      };

      services.authentik.loadBalancer.servers = [ { url = "http://127.0.0.1:9000"; } ];
    };
  };
  fileSystems."/var/lib/private/authentik" = {
    device = "/homelab/authentik";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/authentik".d = {
    user = "authentik";
    group = "authentik";
    mode = "700";
  };

  systemd.services.authentik-ldap.environment = {
    # Bind to loopback only — Jellyfin is the only consumer and it's on this
    # same host. Not exposed via Traefik; firewall doesn't open it either.
    AUTHENTIK_LISTEN__LDAP = "127.0.0.1:3389";
    # Not a secret, so it doesn't need to live in the agenix-encrypted
    # environmentFile alongside AUTHENTIK_TOKEN — same backend Traefik proxies to.
    AUTHENTIK_HOST = "http://127.0.0.1:9000";
  };
}
