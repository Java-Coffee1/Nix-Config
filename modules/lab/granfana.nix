{
  ...
}:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = "3232";
        enforce_domain = true;
        enable_gzip = true;
        domain = "gf.jv.ax";
      };
    };
  };

  services.traefik = {
     # ...
     dynamicConfigOptions = {
       http.routers."your.domain" = {
           rule = "Host(`your.domain`) && PathPrefix(`/grafana`)";
           service = "grafana";
       }
       http.services."grafana" = {
           loadBalancer.servers = [ { 
               url = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
           } ] 
       };
     # ...
  };
}

