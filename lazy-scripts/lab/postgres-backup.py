import os 
from datetime import datetime
import subprocess

DB_USER = "postgres"
BACKUP_DIR = "/homelab/test-pgbackups"
TIMESTAMP = datetime.now().strftime("%Y-%m-%d")
BACKUP_FILE = os.path.join(BACKUP_DIR, f"postgres_backup_{TIMESTAMP}.sql")


command = f"pg_dumpall > {BACKUP_FILE}"
subprocess.call(command, shell=True)
subprocess.call(["gzip", BACKUP_FILE])

