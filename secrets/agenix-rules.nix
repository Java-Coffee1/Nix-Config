let
  ###################################
  ## Javi laptop ssh keys
  ###################################
  javi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost";
  userKeys = [ javi ];

  hostkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs1GFeppG5idkG4NUWohoI7aooqs3RTEhnosM41lxC+ root@nixos-btw";
  hostKeys = [ hostkey ];

  ###################################
  ## homelab-nixos-btw ssh host key
  ###################################
  hostkey-homelab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPI8z4PxR0H1riEhLwyBSfrbtb6mvTEhrEZkb5W+AJRd root@homelab-nixos-btw";
  ###################################
  ## linux-iso-btw ssh host key
  ###################################
  hostkey-linux-iso = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHHzdyeeFDjly6UhCLws4v4asgnkULMNDpu6mI21NZf0 root@linux-iso-btw";
  ###################################
  ## email-nixos-btw ssh host key
  ###################################
  hostkey-email = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnFlJw+NyDbXdS3EyrZujhPJ5dPy8rIFwQFhizFns4g root@nixos";
in
{
  ###################################
  ## fw-nixos-btw
  ###################################
  "fw-nixos-btw/wg-private-fw.age".publicKeys = [
    javi
    hostkey
  ];

  ###################################
  ## linux-iso-btw
  ###################################

  "linux-iso-btw/windscribe-wg.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];

  "linux-iso-btw/servarr-env.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];

  "linux-iso-btw/sonarr-api-key.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/radarr-api-key.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/prowlarr-api-key.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/qbittorrent-password.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/seerr-api-key.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/seerr-jellyfin-admin-password.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "linux-iso-btw/lidarr-api-key.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];

  ##################################
  ## homelab-nixos-btw
  ##################################
  "homelab-nixos-btw/cf_api_token.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/mailjet_email_token.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/postgres-password.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/authentik-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/authentik-ldap-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/authentik-token.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/outline-oidc.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/outline-utils-secret.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/outline-secret-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/copyparty-oauth-client.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/copyparty-oauth-cookie.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/grafana-secret-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/grafana-oidc-secret.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/navidrome-lastfm-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/backup-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/backup-ssh-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/gitlab-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/gitea-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "homelab-nixos-btw/yt-dl-password.age".publicKeys = [
    javi
    hostkey-homelab
  ];

  ###################################
  ## email-nixos-btw
  ###################################
  "email-nixos-btw/stalwart-env.age".publicKeys = [
    javi
    hostkey-email
  ];
  "email-nixos-btw/stalwart-backup-ssh-key.age".publicKeys = [
    javi
    hostkey-email
  ];

}
