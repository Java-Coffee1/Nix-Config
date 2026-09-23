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
in
{
  "wg-home-fw.age".publicKeys = [
    javi
    hostkey
  ];

  "cf_api_token.age".publicKeys = [
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
}
