{
  lib,
  config,
  pkgs,
  ...
}:

let
  jellyfin-backup = pkgs.writers.writePython3Bin "jellyfin-backup" { doCheck = false; } ''
    import os
    import tarfile

    SOURCE_DIR = "/homelab/jellyfin"
    BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/jellyfin-backups"
    BACKUP_FILE = os.path.join(BACKUP_DIR, "jellyfin.tar.gz")
    TMP_FILE = BACKUP_FILE + ".tmp"
    os.makedirs(BACKUP_DIR, exist_ok=True)

    with tarfile.open(TMP_FILE, "w:gz") as tar:
        tar.add(SOURCE_DIR, arcname="jellyfin")

    os.replace(TMP_FILE, BACKUP_FILE)
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
