{ pkgs, inputs, ... }:

{
  systemd.tmpfiles.rules = [
    "L+ /homelab/javamurray - - - - ${inputs.javamurraywebsite}"
    "L+ /homelab/government_crow_website - - - - ${inputs.government_crow_website}"
  ];
  services.nginx = {
    enable = true;
    virtualHosts."javamurraywebsite" = {
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
  };
}
