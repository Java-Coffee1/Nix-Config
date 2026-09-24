{
  lib,
  config,
  pkgs,
  ...
}:

let
  #Spelling is madeup by the govermemt to foce contol over people
  mycoolpostgresssssssssbackupscirpt = pkgs.writers.writePython3Bin "postgres-backup" {doCheck = false;} ''
    import os 
    from datetime import datetime
    import subprocess

    DB_USER = "postgres"
    BACKUP_DIR = "/homelab/test-pgbackups"
    TIMESTAMP = datetime.now().strftime("%Y-%m-%d")
    BACKUP_FILE = os.path.join(BACKUP_DIR, f"postgres_backup_{TIMESTAMP}.sql")


    makedir =f"mkdir -p {BACKUP_DIR}"
    subprocess.call(makedir, shell=True)

    command = f"sudo -u postgres pg_dumpall > {BACKUP_FILE}"
    subprocess.call(command, shell=True)
    subprocess.call(["gzip", BACKUP_FILE])
  '';
in
{
  environment.systemPackages = lib.mkIf (!config.javi.isGui) [ mycoolpostgresssssssssbackupscirpt ];
}
