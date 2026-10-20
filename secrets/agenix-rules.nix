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
  hostkey-linux-iso = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPwvS+OwqTWUrCuY72jUOtYAiltZPw2UkOVM98wniJT root@linux-iso-btw";
in
{
  "wg-private-fw.age".publicKeys = [
    javi
    hostkey
  ];

  "cf_api_token.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "mailjet_email_token.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "postgres-password.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "authentik-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "authentik-ldap-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "outline-oidc.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "outline-utils-secret.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "outline-secret-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "copyparty-oauth-client.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "copyparty-oauth-cookie.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "grafana-secret-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "grafana-oidc-secret.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "backup-env.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "backup-ssh-key.age".publicKeys = [
    javi
    hostkey-homelab
  ];
  "wg-private-iso.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
  "wg-psk-iso.age".publicKeys = [
    javi
    hostkey-linux-iso
  ];
}
