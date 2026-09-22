{ pkgs, inputs, ... }:

{
  systemd.tmpfiles.rules = [ "L+ /homelab/javamurray - - - - ${inputs.javamurraywebsite}" ];
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
  };
  services.traefik.dynamicConfigOptions = {
    http.routers.javamurray = {
      rule = "Host(`javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "javamurray";
      tls.certResolver = "letsencrypt";
    };
    http.services.javamurray.loadBalancer.servers = [ { url = "http://127.0.0.1:8081"; } ];
  };
}
