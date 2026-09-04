let 
  javi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost";
  userKeys = [ javi ];
in
{
  "secret.age".publicKeys = [javi];
}