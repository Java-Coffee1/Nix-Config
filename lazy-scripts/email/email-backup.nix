{ config, lib, pkgs, ... }:

let
  # Stalwart's own data lives under /homelab/stalwart (see modules/email/salwart.nix) --
  # etc/data/logs are owned by uid/gid 2000, which is fine since this backup runs as root.
  stalwart-backup = pkgs.writeShellApplication {
    name = "stalwart-backup";
    runtimeInputs = [
      pkgs.openssh
      pkgs.gnutar
      pkgs.gzip
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      export BASE_DIR="/homelab/stalwart"
      export SUB_DIRS="etc data logs"
      export STAGING_DIR="/homelab/backup-staging/stalwart"
      export SSH_KEY="${config.age.secrets.stalwart-backup-ssh-key.path}"
      export REMOTE_USER="javi"
      export REMOTE_HOST="ssh.javamurray.com"
      export REMOTE_PORT="2600"
      export REMOTE_DIR="/homelab/nfs/data-dumpster/backups/stalwart-backups"
      # homelab-nixos-btw's SSH host key, pinned so scp/ssh trust it without touching
      # root's known_hosts (see hostkey-homelab in secrets/agenix-rules.nix).
      export REMOTE_HOST_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPI8z4PxR0H1riEhLwyBSfrbtb6mvTEhrEZkb5W+AJRd"
      export RETENTION_DAYS="14"
      ${builtins.readFile ./bash-scripts/email-backup.sh}
    '';
  };
in
{
  age.secrets.stalwart-backup-ssh-key = {
    file = ../../secrets/email-nixos-btw/stalwart-backup-ssh-key.age;
    owner = "root";
    mode = "400";
  };

  systemd.tmpfiles.rules = [ "d /homelab/backup-staging/stalwart 0700 root root -" ];

  environment.systemPackages = [ stalwart-backup ];

  systemd.services.stalwart-backup = {
    description = "Tar and scp the Stalwart mail server's data to the homelab backup host";
    after = [ "docker-stalwart.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe stalwart-backup;
    };
  };

  systemd.timers.stalwart-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # catches up if the machine was off at the scheduled time
    };
  };
}
