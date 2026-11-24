{ config, pkgs, ... }: {
  age.secrets.authentik-token = {
    file = ../../secrets/homelab-nixos-btw/authentik-token.age;
    owner = "javi";
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "auth-invite";
      runtimeInputs = [
        pkgs.curl
        pkgs.jq
        pkgs.coreutils
      ];
      text = ''
        export AUTHENTIK_URL=https://auth.javamurray.com
        AUTHENTIK_TOKEN=$(cat ${config.age.secrets.authentik-token.path})
        export AUTHENTIK_TOKEN
        ${builtins.readFile ./bash-scripts/auth-invite.sh}
      '';
    })
  ];
}
