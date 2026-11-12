{ ... }:

{
  imports = [
    ./postgres-backup.nix
    ./outline-databackup.nix
    ./jellyfin-backups.nix
    ./immich-backup.nix
    ./shel-backup-server.nix
  ];
}
