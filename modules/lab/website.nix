{ inputs, config, ... }:

{
  imports = [
    "${inputs.pawprints-arcade}"
    inputs.video-dl.nixosModules.default
  ];
  services.pawprints-arcade.dataDir = "/homelab/hundred-hues";
  services.pawprints-arcade.admins = [ "javi" ];
  services.pawprints-arcade.shareUrl = "https://pawprints-arcade.jv.ax";
  services.pawprints-arcade.smtp = {
    host = "10.10.1.150";
    port = 2500;
    from = "noreply@javamurray.com";
  };

  age.secrets.yt-dl-password.file = ../../secrets/yt-dl-password.age;
  services.video-dl = {
    enable = true;
    port = 8099;
    maxFileSizeMB = 15360;
    passwordFile = config.age.secrets.yt-dl-password.path;
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

    http.routers.pawprints_arcade = {
      rule = "Host(`pawprints-arcade.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "hundred-hues";
      tls.certResolver = "letsencrypt";
    };
    http.routers.pawprints_arcade_redirect = {
      rule = "Host(`hundred-hues.jv.ax`) || Host(`www.hundred-hues.jv.ax`) || Host(`hh.jv.ax`) || Host(`www.pawprints-arcade.jv.ax`)";
      entryPoints = [ "https-web" ];
      middlewares = [
        "old-hues-home"
        "old-hues-rest"
      ];
      service = "hundred-hues";
      tls.certResolver = "letsencrypt";
    };
    http.middlewares.old-hues-home.redirectRegex = {
      regex = "^https://[^/]+/?$";
      replacement = "https://pawprints-arcade.jv.ax/hundredhues";
      permanent = true;
    };
    http.middlewares.old-hues-rest.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://pawprints-arcade.jv.ax/\${1}";
      permanent = true;
    };
    http.services.hundred-hues.loadBalancer.servers = [ { url = "http://127.0.0.1:8090"; } ];
    http.routers.video-dl = {
      rule = "Host(`dl.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "video-dl";
      tls.certResolver = "letsencrypt";
    };
    http.services.video-dl.loadBalancer.servers = [ { url = "http://127.0.0.1:8099"; } ];
  };
}
