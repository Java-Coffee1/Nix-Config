{ pkgs, ... }:

{
  # nixpkgs' qmk package is missing a few of qmk_cli's actual dependencies
  # (appdirs/argcomplete/colorama — present in qmk_firmware's own
  # requirements.txt but not in nixpkgs' propagatedBuildInputs), which
  # surfaces as "Could not find module appdirs!" on every invocation.
  nixpkgs.overlays = [
    (final: prev: {
      qmk = prev.qmk.overridePythonAttrs (old: {
        propagatedBuildInputs =
          old.propagatedBuildInputs
          ++ (with final.python3.pkgs; [
            appdirs
            argcomplete
            colorama
          ]);
      });
    })
  ];

  environment.systemPackages = [
    # QMK's own build (`make <kb>:<km>`, invoked by `qmk compile`/`qmk flash`)
    # shells out to a bare `python3` on PATH for its own checks, separate
    # from the self-contained interpreter wrapped inside the qmk package —
    # so it needs the same libs available on a plain `python3` too.
    (pkgs.python3.withPackages (
      ps: with ps; [
        appdirs
        argcomplete
        colorama
        dotty-dict
        hid
        hjson
        jsonschema
        milc
        pygments
        pyserial
        pyusb
        pillow
      ]
    ))

    # Framework RGB Macropad: keymap source of truth is
    # home/javi/dotfiles/qmk/framework-macropad/ (git). This clones Framework's
    # firmware fork on first run (RGB matrix support for this board only
    # exists on their fl16-2026-f9 branch, not master), symlinks the keymap
    # in, and builds — flashing only if asked, with a confirmation pause.
    (pkgs.writeShellApplication {
      name = "macropad";
      runtimeInputs = [ pkgs.qmk pkgs.git ];
      text = ''
        usage() {
          echo "usage: macropad <build|flash>" >&2
          exit 1
        }

        [ $# -eq 1 ] || usage

        fw_dir="$HOME/qmk_firmware"
        branch="fl16-2026-f9"
        keymap_src="$HOME/Nix-Config/home/javi/dotfiles/qmk/framework-macropad"
        keymap_dest="$fw_dir/keyboards/framework/macropad/keymaps/javi"

        if [ ! -d "$fw_dir" ]; then
          echo "Cloning FrameworkComputer/qmk_firmware ($branch) to $fw_dir..."
          git clone --recursive -b "$branch" https://github.com/FrameworkComputer/qmk_firmware.git "$fw_dir"
        fi

        ln -sfn "$keymap_src" "$keymap_dest"

        cd "$fw_dir"

        case "$1" in
          build)
            qmk compile -kb framework/macropad -km javi
            ;;
          flash)
            qmk compile -kb framework/macropad -km javi
            echo "Put the macropad in bootloader mode now (hold pos 1, tap pos 24), then press enter."
            read -r _
            qmk flash -kb framework/macropad -km javi
            ;;
          *)
            usage
            ;;
        esac
      '';
    })
  ];
}
