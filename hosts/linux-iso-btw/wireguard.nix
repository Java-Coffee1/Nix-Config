{ pkgs, ... }:

{
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.javi.extraGroups = [ "wireshark" ];

  # Decrypted on the host, then bind-mounted into the qbittorrent container
  # (see modules/torrenting/torrenting.nix) — the tunnel is built entirely
  # inside that container's network namespace, so qbittorrent physically has
  # no other route out, and nothing else on this host (ssh, etc.) is affected.
  # Each file's whole contents must be just the raw key value (no "VAR=" env
  # prefix) since networking.wireguard.interfaces reads them directly.
  age.secrets.wg-private-iso.file = ../../secrets/wg-private-iso.age;
  age.secrets.wg-psk-iso.file = ../../secrets/wg-psk-iso.age;
}
