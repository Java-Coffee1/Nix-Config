{ pkgs, ... }:

{
  # Use the iPad as a second monitor over wifi. Hyprland makes a fake
  # (headless) output called IPAD, wayvnc streams just that output, and
  # the iPad connects with any VNC app. Run `ipad-monitor start|stop`.
  # `start` prints a QR code, scan it with the iPad camera to connect.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "ipad-monitor";
      runtimeInputs = [
        pkgs.hyprland
        pkgs.wayvnc
        pkgs.iproute2
        pkgs.gnugrep
        pkgs.qrencode
      ];
      text = ''
        case "''${1:-}" in
          start)
            hyprctl output create headless IPAD
            wayvnc --output=IPAD 0.0.0.0 &
            ip=$(ip -4 route get 1.1.1.1 | grep -oP 'src \K\S+')
            qrencode -t ANSIUTF8 "vnc://$ip:5900"
            echo "scan the QR code or connect the iPad to $ip:5900"
            ;;
          stop)
            pkill wayvnc || true
            hyprctl output remove IPAD
            ;;
          *)
            echo "usage: ipad-monitor start|stop" >&2
            exit 1
            ;;
        esac
      '';
    })
  ];

  networking.firewall.allowedTCPPorts = [ 5900 ]; # wayvnc
}
