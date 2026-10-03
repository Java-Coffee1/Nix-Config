{ config, inputs, ... }:

{
  imports = [ inputs.copyparty.nixosModules.default ];

  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  services.copyparty = {
    enable = true;

    # [global]
    settings = {
      i = "127.0.0.1";
      hist = "/var/cache/copyparty"; # keeps the index db off NFS
      no-rescan = true;
      ansi = true;
      usernames = true;
      daw = true;
      shr = "/sharing-is-caring";
      shr-adm = "java";
      rss = true;
      allow-flac = true;
      allow-wav = true;
      name = "File_Browser";
      no-clone = true;
      xdev = true;
      no-robots = true;
      ah-alg = "argon2";
      u2sort = "n";
      df = "1T";
      chmod-f = "660";
      chmod-d = "770"; # must be a string, the module interpolates it
      zm-http = 80;
      zm-https = 443;
      rproxy = -1;
      xff-src = "127.0.0.1";
      idp-h-usr = "X-Forwarded-User";
      idp-h-grp = "X-Forwarded-Groups";
      auth-ord = "idp,pw,ipu";
      idp-login = "https://fs.javamurray.com/oauth2/start";
      idp-login-t = "Login with authentik.javamurray.com";
      idp-logout = "https://fs.javamurray.com/oauth2/sign_out";
    };

    volumes = {
      "/" = {
        path = "/homelab/nfs/data-dumpster/copyparty/root";
        access = {
          r = "@acct";
          a = "Java";
        };
        flags.dots = true;
      };
      "/\${u}/" = {
        path = "/homelab/nfs/data-dumpster/copyparty/user-data/\${u}";
        access = {
          rwmd = "\${u}";
          a = "Java";
        };
        flags = {
          dots = true;
          e2dsa = true;
          e2ts = true;
        };
      };
      "/chaosbox" = {
        path = "/homelab/nfs/data-dumpster/copyparty/chaosbox";
        access = {
          rwmd = "@acct";
          a = "Java";
        };
        flags.dots = true;
      };
      "/immich-data" = {
        path = "/homelab/nfs/data-dumpster/copyparty/user-photos";
        access.r = "Java";
        flags.dots = true;
      };
      "/google-drive" = {
        path = "/mnt/google-drive";
        access.r = "Java";
        flags.dots = true;
      };
      "/linuxisos-audio-book" = {
        path = "/homelab/nfs/data-dumpster/copyparty/linux-isos/audio_books";
        access.rwd = "Java";
        flags.dots = true;
      };
      "/linux-isos" = {
        path = "/homelab/nfs/data-dumpster/copyparty/linux-isos";
        access.rwd = "Java";
        flags.dots = true;
      };
    };
  };

  systemd.services.copyparty = {
    serviceConfig.BindPaths = [ "/homelab/nfs/data-dumpster/copyparty/user-data" ];
  };

  age.secrets.copyparty-oauth-client.file = ../../secrets/copyparty-oauth-client.age;
  age.secrets.copyparty-oauth-cookie.file = ../../secrets/copyparty-oauth-cookie.age;

  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    oidcIssuerUrl = "https://auth.javamurray.com/application/o/copy-party/";
    clientID = "XPbJYzKHyUh3yaiqurqtpkTw1mA6evNnbdRFx0hQ";
    clientSecretFile = config.age.secrets.copyparty-oauth-client.path;
    cookie.secretFile = config.age.secrets.copyparty-oauth-cookie.path;
    cookie.secure = true;
    redirectURL = "https://fs.javamurray.com/oauth2/callback";
    upstream = [ "http://127.0.0.1:3923" ];
    httpAddress = "http://127.0.0.1:4180";
    email.domains = [ "*" ];
    reverseProxy = true;
    setXauthrequest = true;
    passAccessToken = true;
    passHostHeader = true;
    extraConfig = {
      set-authorization-header = true;
      pass-authorization-header = true;
      pass-user-headers = true;
      skip-provider-button = true;
      user-id-claim = "preferred_username";
      skip-auth-route = [ "^/" ]; # lets copyparty handle its own auth
      code-challenge-method = "S256";
    };
  };

  # same routing as your commented-out labels
  services.traefik.dynamicConfigOptions.http = {
    routers.copyparty = {
      rule = "Host(`fs.javamurray.com`)";
      entryPoints = [ "https-web" ]; # match your other native routers
      tls.certResolver = "letsencrypt";
      service = "copyparty";
    };
    services.copyparty.loadBalancer.servers = [ { url = "http://127.0.0.1:4180"; } ];
  };
}
