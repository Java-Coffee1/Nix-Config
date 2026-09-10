let
  javi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost";
  userKeys = [ javi ];

  hostkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs1GFeppG5idkG4NUWohoI7aooqs3RTEhnosM41lxC+ root@nixos-btw";
  hostKeys = [ hostkey ];
in
{
  "wg-home-lab.age".publicKeys = [
    javi
    hostkey
  ];
}
