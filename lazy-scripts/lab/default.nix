{ ... }:

{
  imports = [
    ./postgres-backup.nix
    ./outline-databackup.nix
    ./jellyfin-backups.nix
    ./immich-backup.nix
    # ./gitea-backup.nix
    ./shel-backup-server.nix
    ./auth-invite.nix
  ];
}
