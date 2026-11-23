{ pkgs, ... }:
let
  ddjRev1Rev = "01a3ed1816fc7004a570483674871cb655a4fd2c";
  ddjRev1Repo = "AKOI-TTI/mixxx-";

  ddjRev1MappingXml = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${ddjRev1Repo}/${ddjRev1Rev}/res/controllers/Pioneer%20DDJ-REV1.midi.xml";
    sha256 = "sha256-oBP5X8N0N/o0+hw9gDCwQbMTamfbr+53jTlA1TNuyqo=";
  };
  ddjRev1Scripts = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/${ddjRev1Repo}/${ddjRev1Rev}/res/controllers/Pioneer-DDJ-REV1-scripts.js";
    sha256 = "sha256-68UsxgA+fFz7/im9ZT5dURvdFqIoWWRaC0mg72pLvj0=";
  };
in
{
  environment.systemPackages = [ pkgs.mixxx ];
  services.udev.packages = [ pkgs.mixxx ];

  hjem.users.javi.files = {
    ".mixxx/controllers/Pioneer DDJ-REV1.midi.xml".source = ddjRev1MappingXml;
    ".mixxx/controllers/Pioneer-DDJ-REV1-scripts.js".source = ddjRev1Scripts;
  };
}
