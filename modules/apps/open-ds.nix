{ pkgs, ... }:

let
  pname = "open-ds";
  version = "0.3.1";

  src = pkgs.fetchurl {
    url = "https://github.com/Boomaa23/open-ds/releases/download/v${version}/open-ds-v${version}.jar";
    hash = "sha256-AdbA304WYYjMIWMmzEU//MBMRwn/71WhnLk0w6s9kAk=";
  };

  # The bundled JNativeHook native library links against these X11 libs at
  # runtime; NixOS has no global library path, so point LD_LIBRARY_PATH at
  # them explicitly or the jar fails with UnsatisfiedLinkError on startup.
  nativeLibs = pkgs.lib.makeLibraryPath [
    pkgs.libx11
    pkgs.libxtst
    pkgs.libxkbcommon
    pkgs.libxcb
    pkgs.libxt
    pkgs.libxinerama
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "OpenDS";
    comment = "Lightweight cross-platform FRC Driver Station";
    categories = [ "Development" "Education" "Utility" ];
  };

  data = pkgs.runCommand "${pname}-data" { nativeBuildInputs = [ pkgs.unzip ]; } ''
    install -D -m444 "${src}" "$out/share/${pname}/${pname}.jar"

    unzip -p "${src}" icon.png > icon.png
    install -D -m444 icon.png "$out/share/icons/hicolor/128x128/apps/${pname}.png"

    install -D -m444 "${desktopItem}/share/applications/${pname}.desktop" "$out/share/applications/${pname}.desktop"
  '';

  # JNativeHook extracts its native library next to the jar by default, which
  # fails since the jar lives in the read-only Nix store; -Djnativehook.lib.path
  # redirects that extraction to a writable, per-user cache directory instead.
  launcher = pkgs.writeShellScriptBin pname ''
    dir="$HOME/.cache/${pname}"
    mkdir -p "$dir"
    export LD_LIBRARY_PATH="${nativeLibs}"
    exec ${pkgs.jre}/bin/java --enable-native-access=ALL-UNNAMED -Djnativehook.lib.path="$dir" -jar ${data}/share/${pname}/${pname}.jar "$@"
  '';

  open-ds = pkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = [
      launcher
      data
    ];
  };
in
{
  environment.systemPackages = [ open-ds ];
}
