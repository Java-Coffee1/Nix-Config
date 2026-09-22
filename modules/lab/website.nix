{pkgs, inputs, ... }:

{
  systemd.tmpfiles.rules = [
    "L+ /homelab/javamurray - - - - ${inputs.javamurraywebsite}"
  ];
    services.nginx = {
    enable = true;
    virtualHosts."javamurraywebsite" = {
      listen = [ { addr = "127.0.0.1"; port = 8080; } ];
      root = "/homelab/javamurray/public";
    };
  };
}