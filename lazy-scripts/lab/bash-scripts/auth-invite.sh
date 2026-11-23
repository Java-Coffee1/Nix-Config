#!/usr/bin/env bash
# Create an authentik invitation and email it to someone.
#
# Interactive:  invite.sh
# Direct:       invite.sh someone@example.com "Their Name" [group1,group2]
set -euo pipefail

# --- config ---
AUTHENTIK_URL="${AUTHENTIK_URL:?set AUTHENTIK_URL}"        # e.g. https://auth.javamurray.com
AUTHENTIK_TOKEN="${AUTHENTIK_TOKEN:?set AUTHENTIK_TOKEN}"  # Directory > Tokens
FLOW_SLUG="${FLOW_SLUG:-enrollment}"
SMTP_URL="${SMTP_URL:-smtp://localhost:2525}"              # postfix relay
FROM_ADDR="${FROM_ADDR:-noreply@auth-signup.javamurray.com}"
EXPIRE_DAYS=7

api() {
  curl -fsS -X "$1" "$AUTHENTIK_URL/api/v3$2" \
    -H "Authorization: Bearer $AUTHENTIK_TOKEN" \
    -H "Content-Type: application/json" \
    ${3:+--data "$3"}
}

pick_groups() {
  local names=() picks n
  mapfile -t names < <(api GET "/core/groups/?page_size=500&include_users=false" | jq -r '.results[].name' | sort)

  if [ ${#names[@]} -eq 0 ]; then
    echo "No groups found." >&2
    return
  fi

  echo "Groups:" >&2
  for i in "${!names[@]}"; do
    printf '  %2d) %s\n' "$((i + 1))" "${names[$i]}" >&2
  done

  read -rp "Pick groups (numbers, space separated, blank for none): " picks
  local chosen=()
  for n in $picks; do
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le ${#names[@]} ]; then
      chosen+=("${names[$((n - 1))]}")
    else
      echo "Skipping invalid pick: $n" >&2
    fi
  done

  (IFS=,; echo "${chosen[*]}")
}

# --- get details: from args, or ask ---
if [ $# -ge 2 ]; then
  EMAIL="$1"
  NAME="$2"
  GROUPS_CSV="${3:-}"
else
  read -rp "Email: " EMAIL
  read -rp "Name: " NAME
  GROUPS_CSV=$(pick_groups)

  echo
  echo "Email:  $EMAIL"
  echo "Name:   $NAME"
  echo "Groups: ${GROUPS_CSV:-none}"
  read -rp "Send invite? [y/N] " ok
  [[ "$ok" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }
fi

# look up the enrollment flow's id
FLOW_PK=$(api GET "/flows/instances/$FLOW_SLUG/" | jq -r .pk)

# build the invite body
BODY=$(jq -n \
  --arg name "$(echo "$EMAIL" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9-]/-/g')" \
  --arg expires "$(date -u -d "+$EXPIRE_DAYS days" -Iseconds)" \
  --arg flow "$FLOW_PK" \
  --arg email "$EMAIL" \
  --arg fullname "$NAME" \
  --arg groups "$GROUPS_CSV" \
  '{
    name: $name,
    expires: $expires,
    single_use: true,
    flow: $flow,
    fixed_data: {
      email: $email,
      name: $fullname,
      invite_groups: ($groups | split(",") | map(select(. != "")))
    }
  }')

INVITE_PK=$(api POST "/stages/invitation/invitations/" "$BODY" | jq -r .pk)
LINK="$AUTHENTIK_URL/if/flow/$FLOW_SLUG/?itoken=$INVITE_PK"

# send the email through postfix
curl -fsS "$SMTP_URL" \
  --mail-from "$FROM_ADDR" \
  --mail-rcpt "$EMAIL" \
  --upload-file - <<EOF
From: Javi <$FROM_ADDR>
To: $NAME <$EMAIL>
Subject: You're invited to make an account
Content-Type: text/plain; charset=utf-8

Hey $NAME,

You've been invited to make an account on my server.

Sign up here: $LINK

This link works once and expires in $EXPIRE_DAYS days.

- Javi
EOF

echo "Sent invite to $EMAIL: $LINK"