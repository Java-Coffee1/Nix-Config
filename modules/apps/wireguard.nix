# old config
# [Interface]
# PrivateKey =
# Address = 10.8.0.6/32, fdcc:ad94:bacf:61a4::cafe:6/128
# MTU = 1420
# DNS = 10.1.2.10
#
# [Peer]
# PublicKey = yE/0pzmoshsUAQqjitcYhhiBGtoKokPCPdjgJHbOekU=
# PresharedKey =
# AllowedIPs = 0.0.0.0/0, ::/0
# PersistentKeepalive = 0
# Endpoint = wg.javamurray.com:51820
{ config, ... }: {
  age.secrets.wg-private-fw.file = ../../secrets/wg-private-fw.age;
  networking.networkmanager.unmanaged = [ "interface-name:Home-Lab" ];
  networking.wg-quick.interfaces.Home-Lab = {
    privateKeyFile = config.age.secrets.wg-private-fw.path;
    address = [
      "10.8.0.6/32"
      "fdcc:ad94:bacf:61a4::cafe:6/128"
    ];
    mtu = 1420;
    dns = [ "10.1.2.10" ];

    peers = [
      {
        publicKey = "yE/0pzmoshsUAQqjitcYhhiBGtoKokPCPdjgJHbOekU=";
        allowedIPs = [
          "10.1.0.0/16"
          "10.8.0.0/24"
        ];
        persistentKeepalive = 30;
        endpoint = "wg.javamurray.com:51820";
      }
    ];
  };
}
