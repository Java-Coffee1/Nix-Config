{ ... }:

{
  imports = [
    ./lab/postgres-backup.nix
    ./lab/outline-databackup.nix
    ./lab/jellyfin-backups.nix
  ];
}
