{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.activate-linux ];
  systemd.user.services.activate-linux = {
    description = "Activate Linux watermark";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.activate-linux}/bin/activate-linux -t 'Activate NixOS' -m 'Configure system.productKeyFile'";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
