{ pkgs, ... }:

{
  # Hyprland has no built-in "focus this app if it's already open, else
  # launch it" dispatcher — this fills that gap for the macropad's
  # MACRO(n) binds (keybindings.lua) by matching an existing window's
  # class or title via hyprctl/jq before falling back to exec.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "app-focus-or-launch";
      runtimeInputs = [
        pkgs.hyprland
        pkgs.jq
      ];
      text = ''
        usage() {
          echo "usage: app-focus-or-launch <class|title> <pattern> <command> [args...]" >&2
          exit 1
        }

        [ $# -ge 3 ] || usage
        field="$1"
        pattern="$2"
        shift 2

        case "$field" in
          class | title) ;;
          *) usage ;;
        esac

        address=$(
          hyprctl clients -j |
            jq -r --arg field "$field" --arg pattern "$pattern" \
              '.[] | select(.[$field] | test($pattern; "i")) | .address' |
            head -n1
        )

        if [ -n "$address" ]; then
          # This system's hyprctl parses dispatch arguments as Lua calling
          # into the hl.dsp.* API, not standard Hyprland dispatch syntax
          # (plain "focuswindow address:0x..." silently fails/no-ops).
          hyprctl dispatch "hl.dsp.focus({window = \"address:$address\"})"
        else
          exec "$@"
        fi
      '';
    })
  ];
}
