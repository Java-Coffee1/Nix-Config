# requireFile sources (e.g. cisco-packet-tracer_9) are fetched from
# https://fs.jv.ax/chaosbox/nix-files/<exact file name> instead of needing nix-store --add-fixed.
{ ... }:

{
  nixpkgs.overlays = [ (import ../overlays/requirefile-mirror.nix) ];

  # so nix-shell -p / nix-build '<nixpkgs>' get the overlay too
  nix.nixPath = [
    "nixpkgs=flake:nixpkgs"
    "nixpkgs-overlays=${../overlays}"
  ];
}
