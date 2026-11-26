############################################
## Aerc (terminal email client)
############################################
{ pkgs, ... }:

{ environment.systemPackages = [ pkgs.aerc ]; }
