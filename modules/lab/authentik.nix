{ inputs, config, ... }:

{
  age.secrets.authentik-env.file = ../../secrets/authentik-env.age;
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
    user = "root";
    group = "root";
    mode = "700";
  };
}
