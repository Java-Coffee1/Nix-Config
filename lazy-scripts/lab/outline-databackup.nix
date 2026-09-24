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
        from datetime import datetime
        import tarfile

        SOURCE_DIR = "/homelab/outline/data"
        BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/outline-data-backups"
        TIMESTAMP = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")        
        BACKUP_FILE = os.path.join(BACKUP_DIR, f"outline_backup_{TIMESTAMP}.tar.gz")
        os.makedirs(BACKUP_DIR, exist_ok=True)

        with tarfile.open(BACKUP_FILE, "w:gz") as tar:
            tar.add(SOURCE_DIR, arcname="outline")
      '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ mycooloutlinebackupscript ];
  services.borgbackup.jobs.outline = {
    paths = [ "/homelab/nfs/data-dumpster/backups/outline-backup" ];
    repo = "/homelab/miscellaneous/borg-info/borg-outline";
    encryption.mode = "none";
    startAt = "daily";

    # 1. take the backup
    preHook = ''
      ${lib.getExe mycooloutlinebackupscript}
    '';

    readWritePaths = [ "/homelab/nfs/data-dumpster/backups/outline-backup" ];

    # 3. remove older than 7 days
    prune.keep.within = "7d";
  };
}
