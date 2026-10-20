{
  lib,
  config,
  pkgs,
  ...
}:

let

  ext-database-backup = pkgs.writers.writeBashBin "ext-database-backup" ''
    #!/usr/bin/env bash

    # backup-server.sh
    # Encrypted, incremental, deduplicated backups using restic over SFTP.
    #
    # Unlike a tar+encrypt+rsync approach, restic:
    #   - encrypts client-side (AES-256) before anything leaves this machine
    #   - splits files into content-defined chunks and only uploads chunks
    #     it hasn't seen before (so repeat runs are fast, even at multi-TB
    #     scale, because unchanged data isn't re-read/re-uploaded)
    #   - can resume an interrupted backup instead of starting over
    #   - never needs to stage a full copy of your dataset on local disk
    #
    # Requires: restic, ssh access to the remote host
    #   Install restic:  sudo apt install restic     (Debian/Ubuntu)
    #                     sudo dnf install restic     (Fedora)
    set -Eeuo pipefail

    export PATH="${
      lib.makeBinPath [
        pkgs.restic
        pkgs.curl
        pkgs.openssh
      ]
    }:$PATH"

    ### ------------------- CONFIG -------------------
    # Secrets come from agenix (DISCORD_WEBHOOK_URL, RESTIC_PASSWORD)
    set -a
    source "${config.age.secrets.backup-env.path}"
    set +a

    declare webhook_url="$DISCORD_WEBHOOK_URL"

    # Directories you want backed up (set javi.backupPaths in any module)
    declare -a source_dirs=(
      ${lib.escapeShellArgs config.javi.backupPaths}
    )

    # Remote repository, over SFTP.
    # SSH private key comes from agenix (backup-ssh-key)

    declare ssh_port=26101
    declare ssh_key="${config.age.secrets.backup-ssh-key.path}"
    export RESTIC_REPOSITORY="sftp://java@java-files.shelvacu.com:$ssh_port//data"

    # Passed to every restic call so its ssh uses the key file above
    declare -a restic_opts=(-o "sftp.args=-i $ssh_key")

    # RESTIC_PASSWORD (from agenix above) is the repository password. It encrypts the
    # repo key — restic itself does the actual AES-256 encryption of your
    # data using a key that's derived from and protected by this
    # password. Losing it (with no other copy) means your backups
    # become permanently unreadable, even to you. Back it up offline.

    # Retention policy: keep every snapshot from the last $keep_within,
    # plus the newest snapshot from each of the last $keep_monthly months.
    # Older ones get deleted and their now-unused data chunks reclaimed.
    # Durations look like 30d, 3m, 1y, 1y6m (weeks aren't supported)
    declare keep_within="30d"
    declare keep_monthly=6

    # Patterns to skip (Docker overlay junk, caches, etc.) — edit as needed
    declare -a excludes=(
    )


    ### ------------------------------------------------

    send_webhook() {
        local message="$1"

        # Escape quotes and backslashes
        message="''${message//\\/\\\\}"
        message="''${message//\"/\\\"}"

        curl -sS \
            -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\":\"$message\"}" \
            "$webhook_url" >/dev/null || true
    }

    # log() {
    #   declare current_time
    #   current_time="$(date '+%H:%M:%S')"
    #   echo "[$current_time] $*" >&2
    # }
    log() {
        local current_time
        current_time="$(date '+%H:%M:%S')"

        local msg="[$current_time] $*"

        echo "$msg" >&2
        send_webhook "$msg"
    }

    verbose_run() {
      declare cmd_str
      printf -v cmd_str '%q ' "$@"
      cmd_str="''${cmd_str% }"
      log "running: $cmd_str"
      "$@"
    }

    retry() {
      local max_attempts=3 delay=10 attempt=1 rc=0
      until "$@"; do
        rc=$?
        if (( attempt >= max_attempts )); then
          return "$rc"
        fi
        log "Command failed (attempt $attempt/$max_attempts), retrying in ''${delay}s: $*"
        sleep "$delay"
        ((attempt++))
        delay=$((delay * 2))
      done
    }

    on_error() {
      log "Backup FAILED (exit $1, line $2): $BASH_COMMAND"
    }
    trap 'on_error $? $LINENO' ERR

    check_requirements() {
      if ! command -v restic >/dev/null; then
        echo "ERROR: 'restic' is not installed. Install it with:" >&2
        echo "  sudo apt install restic    (Debian/Ubuntu)" >&2
        echo "  sudo dnf install restic    (Fedora)" >&2
        exit 1
      fi

      if [[ -z "''${RESTIC_PASSWORD:-}" ]]; then
        log "RESTIC_PASSWORD is missing from ${config.age.secrets.backup-env.path}"
        exit 1
      fi

      if [[ ! -r "$ssh_key" ]]; then
        log "SSH key is missing or unreadable at $ssh_key"
        exit 1
      fi
    }

    ensure_repo() {
      # Clears a lock left behind by a run that got killed (OOM, systemctl stop,
      # power loss). Only removes locks that are actually stale — restic checks
      # the lock's recorded host/PID before touching it, so a lock held by a
      # genuinely running backup is left alone.
      restic "''${restic_opts[@]}" unlock >/dev/null 2>&1 || true

      if retry restic "''${restic_opts[@]}" snapshots >/dev/null 2>&1; then
        return 0
      fi
      log "No existing restic repository found at $RESTIC_REPOSITORY — initializing."
      verbose_run restic "''${restic_opts[@]}" init
    }

    # Runs a restic command, streaming its output live (so `journalctl -f`
    # still shows progress as it happens) while also capturing restic's own
    # summary lines and re-logging them through log(), since restic prints
    # those straight to stdout/stderr and they'd otherwise never reach Discord.
    run_with_summary() {
      local out_file rc=0
      out_file="$(mktemp)"
      "$@" 2>&1 | tee "$out_file" || rc=$?

      local summary
      summary="$(grep -E '^(Files:|Dirs:|Added to the repository:|processed |snapshot .* saved)' "$out_file" | paste -sd '; ' -)"
      rm -f "$out_file"
      if [[ -n "$summary" ]]; then
        log "$summary"
      fi
      return "$rc"
    }

    run_backup() {
      declare -a exclude_args=()
      for pattern in "''${excludes[@]}"; do
        exclude_args+=(--exclude "$pattern")
      done

      log "Starting backup of ''${#source_dirs[@]} director(y/ies)"
      retry run_with_summary verbose_run restic "''${restic_opts[@]}" backup "''${source_dirs[@]}" "''${exclude_args[@]}"
    }

    prune_old_snapshots() {
      log "Applying retention policy (within=$keep_within monthly=$keep_monthly) and pruning"
      retry verbose_run restic "''${restic_opts[@]}" forget \
        --group-by host \
        --keep-within "$keep_within" \
        --keep-monthly "$keep_monthly" \
        --prune
    }

    check_requirements
    ensure_repo
    run_backup
    prune_old_snapshots
    log "Backup complete."

  '';

in
{
  options.javi.backupPaths = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Folders backed up by ext-database-backup. Lists from every module get merged into one.";
  };

  config = {
    age.secrets.backup-env = {
      file = ../../secrets/backup-env.age;
      owner = "javi";
      mode = "400";
    };

    age.secrets.backup-ssh-key = {
      file = ../../secrets/backup-ssh-key.age;
      owner = "javi";
      mode = "400";
    };

    javi.backupPaths = [
      "/homelab/vaultwarden"
      "/homelab/nfs/data-dumpster"
    ];

    environment.systemPackages = lib.mkIf (!config.javi.isGui) [ ext-database-backup ];

    systemd.services.ext-database-backup = {
      description = "Run custom script backup scirpt";
      # No $HOME means restic can't find/create its cache dir, so every run
      # re-reads and re-hashes all source files instead of skipping unchanged ones.
      environment.HOME = "/root";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe ext-database-backup;
      };
    };

    # 2. Define the scheduling trigger
    systemd.timers.ext-database-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly"; # Triggers daily (Alternative format: "*-*-* 02:00:00")
        Persistent = true; # Catches up if the machine was off during execution time
      };
    };
  };
}
