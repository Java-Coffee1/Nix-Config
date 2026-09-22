{ config, ... }:

{
  imports = [
    ./traefik-config/middlewares.nix
    ./traefik-config/routes.nix
    ./traefik-config/tcp.nix
  ];
  services.traefik.dataDir = "/homelab/traefik";

  age.secrets.cf_api_token.file = ../../secrets/cf_api_token.age;

  services.traefik.enable = true;
  services.traefik.environmentFiles = [ config.age.secrets.cf_api_token.path ];
  services.traefik.staticConfigOptions = {
    entryPoints = {
      http-web = {
        address = ":81";
        asDefault = true;
        http.redirections.entryPoint = {
          to = "https-web";
          scheme = "https";
        };
      };
      https-web = {
        address = ":444";
        asDefault = true;
        http.tls.certResolver = "letsencrypt";
      };
    };
    log = {
      level = "INFO";
      filePath = "${config.services.traefik.dataDir}/traefik.log";
      format = "json";
    };

    certificatesResolvers.letsencrypt.acme = {
      email = "julianmurray4152@gmail.com";
      storage = "${config.services.traefik.dataDir}/acme.json";
      httpChallenge.entryPoint = "http-web";
    };

    certificatesResolvers.gcloud.acme = {
      email = "julianmurray4152@gmail.com";
      storage = "${config.services.traefik.dataDir}/acme-gcloud.json";
      dnsChallenge.provider = "cloudflare";
    };

    api.dashboard = true;
    # Access the Traefik dashboard on <Traefik IP>:8080 of your server
    api.insecure = true;
  };

  networking.firewall.allowedTCPPorts = [
    81
    444
  ];
}
