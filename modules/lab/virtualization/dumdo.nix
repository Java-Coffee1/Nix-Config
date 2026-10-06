{
  # https://github.com/DumbWareio/DumbDo
  virtualisation.oci-containers.containers.dumbdo = {
    image = "dumbwareio/dumbdo:latest";
    pull = "always";
    environment = {
      DUMBDO_SITE_TITLE = "Argyle Choices Requests";
      ALLOWED_ORIGINS = "https://choices.javamurray.com, https://c.javamurray.com, https://choices.jv.ax";
      # no DUMBDO_PIN set, anyone with the link can use it
    };
    volumes = [ "/homelab/dumbdo:/app/data" ];
    ports = [ "127.0.0.1:8091:3000" ];
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/dumbdo".d = {
    user = "root";
    group = "homelab-admin";
    mode = "770";
  };
  services.traefik.dynamicConfigOptions = {
    http.routers.dumbdo = {
      rule = "Host(`choices.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "dumbdo";
      middlewares = [ "middlewares-rate-limit" ];
      tls.certResolver = "letsencrypt";
    };
    http.routers.dumbdo-redirect = {
      rule = "Host(`choices.javamurray.com`) || Host(`c.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "dumbdo";
      middlewares = [ "dumbdo-redirect" ];
      tls.certResolver = "letsencrypt";
    };
    http.middlewares.dumbdo-redirect.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://choices.jv.ax/\${1}";
      permanent = true;
    };
    http.services.dumbdo.loadBalancer.servers = [ { url = "http://127.0.0.1:8091"; } ];
  };
}
