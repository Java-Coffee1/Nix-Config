{
  lib,
  config,
  pkgs,
  ...
}:

let
  gitea-backup = pkgs.writers.writePython3Bin "gitea-backup" { doCheck = false; } ''
    import os
    import tarfile

    SOURCE_DIR = "/homelab/gitea"
    BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/gitea-backups"
    BACKUP_FILE = os.path.join(BACKUP_DIR, "gitea.tar.gz")
    TMP_FILE = BACKUP_FILE + ".tmp"
    os.makedirs(BACKUP_DIR, exist_ok=True)

    with tarfile.open(TMP_FILE, "w:gz") as tar:
        tar.add(SOURCE_DIR, arcname="gitea")

    os.replace(TMP_FILE, BACKUP_FILE)
  '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ gitea-backup ];
  services.borgbackup.jobs.gitea = {
    paths = [ "/homelab/nfs/data-dumpster/backups/gitea-backups" ];
    repo = "/homelab/nfs/data-dumpster/backups/borg-info/borg-gitea";
    encryption.mode = "none";
    startAt = "daily";

    # 1. take the backup
    preHook = ''
      ${lib.getExe gitea-backup}
    '';

    readWritePaths = [ "/homelab/nfs/data-dumpster/backups/gitea-backups" ];

    # 3. remove older than 7 days
    prune.keep.within = "7d";
  };
}
