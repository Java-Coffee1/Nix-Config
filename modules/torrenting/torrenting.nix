{ config, ... }:

let
  # homelab-nixos-btw, running Traefik/Authentik — the only host qbittorrent's
  # local-address auth bypass should ever trust.
  authProxy = "10.10.1.170";
  dataDir = "/linux-isos-data/qbittorrent";
  webuiPort = 4032;

  # the container's veth address on the host side — once port 4032 is
  # restricted to authProxy below, this is the only thing that can ever
  # appear as qbittorrent's apparent source (systemd-nspawn's port forwarding
  # masquerades the real client IP as this address), so it's safe to trust.
  containerHostAddress = "10.233.1.1";
  containerLocalAddress = "10.233.1.2";
in
{
  # qbittorrent lives in its own network namespace (a NixOS container) whose
  # only interface besides loopback+veth is the wg-switzerland tunnel — so
  # its traffic physically has no path except through the VPN, and nothing
  # else on this host (ssh, etc.) is affected. This is the "docker network"
  # equivalent on NixOS: containers.* gives each container its own netns +
  # veth pair back to the host, with forwardPorts doing the port-publish NAT.
  containers.qbittorrent = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = containerHostAddress;
    localAddress = containerLocalAddress;

    forwardPorts = [
      {
        protocol = "tcp";
        hostPort = webuiPort;
        containerPort = webuiPort;
      }
    ];

    bindMounts = {
      "/run/wg-secrets/private-key" = {
        hostPath = config.age.secrets.wg-private-iso.path;
        isReadOnly = true;
      };
      "/run/wg-secrets/psk" = {
        hostPath = config.age.secrets.wg-psk-iso.path;
        isReadOnly = true;
      };
      ${dataDir} = {
        hostPath = dataDir;
        isReadOnly = false;
      };
    };

    config = { ... }: {
      system.stateVersion = "26.05";

      networking.nameservers = [ "10.255.255.1" ];

      networking.wireguard.interfaces.wg-switzerland = {
        ips = [ "100.124.236.134/32" ];
        privateKeyFile = "/run/wg-secrets/private-key";
        mtu = 1420;
        peers = [
          {
            publicKey = "G7LkwWk08Ase/Wi9mnOW77brNBC0vTCemvy1IW1nlV4=";
            presharedKeyFile = "/run/wg-secrets/psk";
            endpoint = "zrh-317-wg.whiskergalaxy.com:1194";
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
          }
        ];
      };

      services.qbittorrent = {
        enable = true;
        webuiPort = webuiPort;
        profileDir = dataDir;
        serverConfig = {
          BitTorrent.Session.DefaultSavePath = dataDir;
          Preferences.WebUI = {
            # Auth is handled upstream by the reverse proxy (authentik forwardAuth).
            # Port 4032 is only reachable from authProxy (see host firewall rule
            # below), and systemd-nspawn's port forwarding masquerades every
            # forwarded connection's source as containerHostAddress — so trusting
            # that fixed address here is equivalent to trusting authProxy.
            AuthSubnetWhitelistEnabled = true;
            AuthSubnetWhitelist = "${containerHostAddress}/32";
            # qbittorrent rejects requests whose Host header isn't localhost/the
            # bind IP unless this is off — the proxy forwards Host: qbit.jv.ax,
            # which would otherwise get a 401 regardless of the auth bypass above.
            HostHeaderValidation = false;
          };
        };
      };
    };
  };

  # Restrict the forwarded WebUI port to the trusted proxy before it ever
  # reaches the container's NAT — raw/PREROUTING runs before any nat table,
  # so this holds regardless of how systemd-nspawn implements the port
  # forward. Needs live verification once the host is reachable again.
  networking.firewall.extraCommands = ''
    iptables -t raw -F PREROUTING
    iptables -t raw -I PREROUTING 1 -p tcp --dport ${toString webuiPort} -j DROP
    iptables -t raw -I PREROUTING 1 -p tcp --dport ${toString webuiPort} -s ${authProxy} -j ACCEPT
  '';
}
