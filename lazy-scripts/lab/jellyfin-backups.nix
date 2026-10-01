{
  lib,
  config,
  pkgs,
  ...
}:

let
  jellyfin-backup = pkgs.writers.writePython3Bin "jellyfin-backup" { doCheck = false; } ''
    import os 
    from datetime import datetime
    import tarfile

    SOURCE_DIR = "/homelab/jellyfin"
    BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/jellyfin-backups"
    TIMESTAMP = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")        
    BACKUP_FILE = os.path.join(BACKUP_DIR, f"jellyfin_{TIMESTAMP}.tar.gz")
    os.makedirs(BACKUP_DIR, exist_ok=True)

    with tarfile.open(BACKUP_FILE, "w:gz") as tar:
        tar.add(SOURCE_DIR, arcname="jellyfin")
  '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ jellyfin-backup ];
  services.borgbackup.jobs.jellyfin = {
    paths = [ "/homelab/nfs/data-dumpster/backups/jellyfin-backups" ];
    repo = "/homelab/miscellaneous/borg-info/borg-jellyfin";
    encryption.mode = "none";
    startAt = "daily";

    # 1. take the backup
    preHook = ''
      ${lib.getExe jellyfin-backup}
    '';

    readWritePaths = [ "/homelab/nfs/data-dumpster/backups/jellyfin-backups" ];

    # 3. remove older than 7 days
    prune.keep.within = "7d";
  };
}
