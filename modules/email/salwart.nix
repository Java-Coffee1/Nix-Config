{ config, ... }:
let
  dataEtc = "/homelab/stalwart/etc";
  dataDir = "/homelab/stalwart/data";
  dataLog = "/homelab/stalwart/logs";
in
{
  age.secrets.stalwart-env.file = ../../secrets/email-nixos-btw/stalwart-env.age;

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.stalwart = {
    image = "stalwartlabs/stalwart:v1.2.0";
    pull = "always";
    extraOptions = [ "--init" ];
    environmentFiles = [ config.age.secrets.stalwart-env.path ];
    ports = [
      "25:25"
      "465:465"
      "993:993"
      "995:995"
      "4190:4190"
      "443:443"
      "127.0.0.1:8080:8080"
    ];
    volumes = [
      "${dataEtc}:/etc/stalwart"
      "${dataDir}:/var/lib/stalwart"
      "${dataLog}:/var/log/stalwart"
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${dataEtc} 0750 2000 2000 -"
    "d ${dataDir} 0750 2000 2000 -"
    "d ${dataLog} 0750 2000 2000 -"
  ];
  systemd.services.docker-stalwart = {
    after = [ "systemd-tmpfiles-setup.service" ];
    requires = [ "systemd-tmpfiles-setup.service" ];
  };
}
