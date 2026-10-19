{
  lib,
  config,
  pkgs,
  ...
}:

let
  #Spelling is madeup by the govermemt to foce contol over people
  mycoolpostgresssssssssbackupscirpt =
    pkgs.writers.writePython3Bin "postgres-backup" { doCheck = false; }
      ''
        import os
        import subprocess

        DB_USER = "postgres"
        BACKUP_DIR = "/homelab/nfs/data-dumpster/backups/postgres-backup"
        BACKUP_FILE = os.path.join(BACKUP_DIR, "postgres_backup.sql")
        TMP_FILE = BACKUP_FILE + ".tmp"

        makedir =f"mkdir -p {BACKUP_DIR}"
        subprocess.call(makedir, shell=True)

        command = f"sudo -u postgres pg_dumpall > {TMP_FILE}"
        subprocess.call(command, shell=True)
        subprocess.call(["gzip", "-f", TMP_FILE])
        os.replace(f"{TMP_FILE}.gz", f"{BACKUP_FILE}.gz")
      '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ mycoolpostgresssssssssbackupscirpt ];
  services.borgbackup.jobs.postgres = {
    paths = [ "/homelab/nfs/data-dumpster/backups/postgres-backup" ];
    repo = "/homelab/miscellaneous/borg-info/borg-postgres";
    encryption.mode = "none";
    startAt = "daily";

    # 1. take the backup
    preHook = ''
      ${lib.getExe mycoolpostgresssssssssbackupscirpt}
    '';

    readWritePaths = [ "/homelab/nfs/data-dumpster/backups/postgres-backup" ];

    # 3. remove older than 7 days
    prune.keep.within = "7d";
  };
}
