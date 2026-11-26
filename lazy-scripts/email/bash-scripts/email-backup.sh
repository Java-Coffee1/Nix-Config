#!/usr/bin/env bash
# Tar up the Stalwart mail server's etc/data/logs and scp the archive to a remote backup host.
set -euo pipefail

BASE_DIR="${BASE_DIR:?set BASE_DIR}"
SUB_DIRS="${SUB_DIRS:?set SUB_DIRS}"               # space-separated, relative to BASE_DIR
STAGING_DIR="${STAGING_DIR:?set STAGING_DIR}"
SSH_KEY="${SSH_KEY:?set SSH_KEY}"
REMOTE_USER="${REMOTE_USER:?set REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST:?set REMOTE_HOST}"
REMOTE_PORT="${REMOTE_PORT:?set REMOTE_PORT}"
REMOTE_DIR="${REMOTE_DIR:?set REMOTE_DIR}"
REMOTE_HOST_KEY="${REMOTE_HOST_KEY:?set REMOTE_HOST_KEY}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >&2
}

read -ra sub_dirs <<< "$SUB_DIRS"

mkdir -p "$STAGING_DIR"

timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
archive="$STAGING_DIR/stalwart-$timestamp.tar.gz"
tmp_archive="$archive.tmp"

log "Archiving ${sub_dirs[*]} (under $BASE_DIR) -> $archive"
tar -czf "$tmp_archive" -C "$BASE_DIR" "${sub_dirs[@]}"
mv "$tmp_archive" "$archive"

# Pin the remote host key so scp/ssh can't be MITM'd into trusting an impostor,
# without relying on whatever happens to be in root's ~/.ssh/known_hosts.
known_hosts="$(mktemp)"
trap 'rm -f "$known_hosts"' EXIT
echo "[$REMOTE_HOST]:$REMOTE_PORT $REMOTE_HOST_KEY" > "$known_hosts"

ssh_opts=(-i "$SSH_KEY" -p "$REMOTE_PORT" -o UserKnownHostsFile="$known_hosts" -o StrictHostKeyChecking=yes)

log "Ensuring remote directory $REMOTE_DIR exists on $REMOTE_HOST"
# shellcheck disable=SC2029 # REMOTE_DIR is ours, meant to expand client-side
ssh "${ssh_opts[@]}" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p '$REMOTE_DIR'"

log "Sending $archive to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR via scp"
scp -i "$SSH_KEY" -P "$REMOTE_PORT" -o UserKnownHostsFile="$known_hosts" -o StrictHostKeyChecking=yes \
  "$archive" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

log "Pruning local staging archives older than $RETENTION_DAYS days"
find "$STAGING_DIR" -maxdepth 1 -name 'stalwart-*.tar.gz' -mtime "+$RETENTION_DAYS" -print -delete

log "Pruning remote archives older than $RETENTION_DAYS days"
# shellcheck disable=SC2029 # REMOTE_DIR/RETENTION_DAYS are ours, meant to expand client-side
ssh "${ssh_opts[@]}" "$REMOTE_USER@$REMOTE_HOST" \
  "find '$REMOTE_DIR' -maxdepth 1 -name 'stalwart-*.tar.gz' -mtime +$RETENTION_DAYS -print -delete"

log "Backup complete: $archive"
