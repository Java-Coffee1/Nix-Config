{ pkgs, ... }:

let
  pname = "first-driver-station";
  version = "2027.0.0-alpha-8";

  src = pkgs.fetchurl {
    url = "https://github.com/crueter/FirstDriverStation-AppImage/releases/download/v2027.0.0-alpha-8%402026-10-22_1792673535/FirstDriverStation-linux-x64-2027.0.0-alpha-8.AppImage";
    hash = "sha256-zxB6R8331L8HnBss44lg2LPjQDoehWBPyrJW/nD487A=";
  };

  # This AppImage embeds a dwarfs filesystem instead of squashfs, so
  # pkgs.appimageTools (which hardcodes unsquashfs) can't extract or run it.
  # Replicate appimage-run's own offset formula (end of the ELF section
  # header table) and extract with dwarfsextract instead.
  appdir =
    pkgs.runCommand "${pname}-${version}-appdir"
      {
        nativeBuildInputs = [
          pkgs.dwarfs
          pkgs.binutils-unwrapped
        ];
      }
      ''
        offset=$(LC_ALL=C readelf -h ${src} | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
        mkdir -p "$out"
        dwarfsextract -i ${src} --image-offset "$offset" -o "$out"
      '';

  # The bundle is a "sharun"-style self-contained AppImage: it ships its own
  # ld.so/libc under $APPDIR/lib, so it runs without appimageTools' FHS/
  # bubblewrap wrapper. CI=true skips an interactive pkexec prompt the
  # bundle uses to install its udev rule itself; the same rule is installed
  # declaratively below instead. DOTNET_SYSTEM_GLOBALIZATION_INVARIANT
  # avoids a missing-libicu crash, since this build doesn't bundle ICU.
  launcher = pkgs.writeShellScriptBin pname ''
    export APPDIR="${appdir}"
    export CI=true
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    exec "$APPDIR/AppRun" "$@"
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "FIRST Driver Station";
    comment = "Official FRC/FTC driver station (2027 season, alpha)";
    categories = [
      "Game"
      "Education"
    ];
  };

  data = pkgs.runCommand "${pname}-data" { } ''
    install -D -m444 "${appdir}/FirstDriverStation.png" "$out/share/icons/hicolor/512x512/apps/${pname}.png"
    install -D -m444 "${desktopItem}/share/applications/${pname}.desktop" "$out/share/applications/${pname}.desktop"
  '';

  first-driver-station = pkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = [
      launcher
      data
    ];
  };
in
{
  environment.systemPackages = [ first-driver-station ];

  # Lets the DS talk to joysticks/HID gamepads without running as root;
  # `uaccess` grants the active logind seat user access automatically.
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", TAG+="uaccess"
  '';
}
