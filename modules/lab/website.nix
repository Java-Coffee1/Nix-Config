{ inputs, ... }:

{
  imports = [ "${inputs.hundred_hues_website}" ];
  services.hundred-hues.dataDir = "/homelab/hundred-hues";
  services.hundred-hues.admins = [ "javi" ];
  services.hundred-hues.shareUrl = "https://hh.jv.ax";
  services.hundred-hues.smtp = {
    host = "10.10.1.150";
    port = 2500;
    from = "noreply@javamurray.com";
  };
  
  systemd.tmpfiles.rules = [
    "L+ /homelab/javamurray - - - - ${inputs.javamurraywebsite}"
    "L+ /homelab/government_crow_website - - - - ${inputs.government_crow_website}"
  ];
  services.nginx = {
    enable = true;
    commonHttpConfig = "absolute_redirect off;";
    virtualHosts."javamurray.com" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8081;
        }
      ];
      root = "/homelab/javamurray/public";
    };
    virtualHosts."government_crow_website" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8082;
        }
      ];
      root = "/homelab/government_crow_website/public";
    };
  };

  services.traefik.dynamicConfigOptions = {
    http.routers.javamurray = {
      rule = "Host(`javamurray.com`) || Host(`www.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "javamurray";
      middlewares = [ "redirect-to-www" ];
      tls.certResolver = "letsencrypt";
    };
    http.services.javamurray.loadBalancer.servers = [ { url = "http://127.0.0.1:8081"; } ];

    http.routers.government_crow_website = {
      rule = "Host(`governmentcrow.net`) || Host(`www.governmentcrow.net`)";
      entryPoints = [ "https-web" ];
      service = "government_crow_website";
      middlewares = [ "redirect-to-www" ];
      tls.certResolver = "letsencrypt";
    };
    http.services.government_crow_website.loadBalancer.servers = [ { url = "http://127.0.0.1:8082"; } ];

    http.routers.hundred_hues_website = {
      rule = "Host(`hundred-hues.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "hundred-hues";
      tls.certResolver = "letsencrypt";
    };
    http.routers.hundred_hues_redirect = {
      rule = "Host(`hh.jv.ax`) || Host(`www.hundred-hues.jv.ax`)";
      entryPoints = [ "https-web" ];
      middlewares = [ "hundred-hues-redirect" ];
      service = "hundred-hues";
      tls.certResolver = "letsencrypt";
    };
    http.middlewares.hundred-hues-redirect.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://hundred-hues.jv.ax/\${1}";
      permanent = true;
    };
    http.services.hundred-hues.loadBalancer.servers = [ { url = "http://127.0.0.1:8090"; } ];
  };
}
