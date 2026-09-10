{ config, ... }: {
  age.secrets.wg-private-fw.file = ../../secrets/wg-private-fw.age;

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.wg-private-fw.path ];

    profiles.Home-Lab = {
      connection = {
        id = "Home-Lab";
        type = "wireguard";
        interface-name = "Home-Lab";
        autoconnect = "false";
      };
      wireguard = {
        private-key = "$WG_HOME_LAB_KEY";
        mtu = 1420;
      };
      "wireguard-peer.yE/0pzmoshsUAQqjitcYhhiBGtoKokPCPdjgJHbOekU=" = {
        endpoint = "wg.javamurray.com:51820";
        preshared-key = "z9Y2Dns4t4zcsPBsdJdoAxDttIaOKS+N/hHiONreMBA=";
        preshared-key-flags = 0;
        allowed-ips = "10.1.0.0/16;10.8.0.0/24;10.25.25.0/24;";
        persistent-keepalive = 30;
      };
      ipv4 = {
        method = "manual";
        address1 = "10.8.0.6/32";
        dns = "10.1.2.10;";
      };
      ipv6 = {
        method = "manual";
        address1 = "fdcc:ad94:bacf:61a4::cafe:6/128";
      };
    };
  };
}
