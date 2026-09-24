{ pkgs, ... }:

let
  eez-studio =
    let
      pname = "eez-studio";
      version = "0.29.0";

      src = pkgs.fetchurl {
        url = "https://github.com/eez-open/studio/releases/download/v${version}/EEZ-Studio-${version}.AppImage";
        hash = "sha256-Jb9ioe1uWYkBkBwp6Fn5lcp2ikUXeeEFRj3KM2tJdVI=";
      };

      appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        install -m 444 -D "${appimageContents}/EEZ Studio.desktop" "$out/share/applications/${pname}.desktop"
        substituteInPlace "$out/share/applications/${pname}.desktop" \
          --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U' \
          --replace-fail 'Icon=EEZ Studio' 'Icon=${pname}'

        for size in 16 32 48 64 128 256 512; do
          install -D "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/EEZ Studio.png" \
            "$out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png"
        done
      '';
    };
in
{
  environment.systemPackages = [ eez-studio ];
}
