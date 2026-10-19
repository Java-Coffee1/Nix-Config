{
  lib,
  config,
  pkgs,
  ...
}:

let
  #Spelling is madeup by the govermemt to foce contol over people
  mycooloutlinebackupscript =
    pkgs.writers.writePython3Bin "outline-data-backup" { doCheck = false; }
      ''
        import os
        import tarfile

        SOURCE_DIR = "/homelab/outline/data"
        BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/outline-data-backups"
        BACKUP_FILE = os.path.join(BACKUP_DIR, "outline.tar.gz")
        TMP_FILE = BACKUP_FILE + ".tmp"
        os.makedirs(BACKUP_DIR, exist_ok=True)

        with tarfile.open(TMP_FILE, "w:gz") as tar:
            tar.add(SOURCE_DIR, arcname="outline")

        os.replace(TMP_FILE, BACKUP_FILE)
      '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ mycooloutlinebackupscript ];
  services.borgbackup.jobs.outline = {
    paths = [ "/homelab/nfs/data-dumpster/backups/outline-data-backups" ];
    repo = "/homelab/miscellaneous/borg-info/borg-outline";
    encryption.mode = "none";
    startAt = "daily";

    # 1. take the backup
    preHook = ''
      ${lib.getExe mycooloutlinebackupscript}
    '';

    readWritePaths = [ "/homelab/nfs/data-dumpster/backups/outline-data-backups" ];

    # 3. remove older than 7 days
    prune.keep.within = "7d";
  };
}
