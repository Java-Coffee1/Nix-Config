let
  dataDir = "/homelab/bulwark";
in
{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.bulwark = {
    image = "ghcr.io/bulwarkmail/webmail:1.22.0";
    pull = "always";
    dependsOn = [ "stalwart" ];
    environment = {
      HOSTNAME = "0.0.0.0";
      PORT = "3000";
      JMAP_SERVER_URL = "https://mail.jv.ax";
    };
    ports = [ "3000:3000" ];
    volumes = [ "${dataDir}:/app/data" ];
    extraOptions = [
      "--health-cmd=wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1"
      "--health-interval=30s"
      "--health-timeout=5s"
      "--health-retries=3"
      "--health-start-period=10s"
    ];
  };

  systemd.tmpfiles.rules = [ "d ${dataDir} 0750 2000 2000 -" ];
}
