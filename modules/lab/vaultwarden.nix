{
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:latest";
    pull = "always";
    environment = {
      DOMAIN = "https://vault.jv.ax";
    };
    volumes = [ "/homelab/vaultwarden:/data" ];
    ports = [ "127.0.0.1:8000:80" ];
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/vaultwarden".d = {
    user = "root";
    group = "homelab-admin";
    mode = "770";
  };

  services.traefik.dynamicConfigOptions = {
    http.routers.vaultwarden = {
      rule = "Host(`vault.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "vaultwarden";
      tls.certResolver = "letsencrypt";
    };
    http.services.vaultwarden.loadBalancer.servers = [ { url = "http://127.0.0.1:8000"; } ];
  };
}