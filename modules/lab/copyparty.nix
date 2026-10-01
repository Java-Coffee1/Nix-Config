{ config, inputs, ... }:
let
  nas = "10.30.30.101:/mnt/DataDumpster";
  nfs = device: {
    inherit device;
    fsType = "nfs";
    options = [ "nfsvers=4" ];
  };
  mounts = {
    "/homelab/nfs/copyparty/user-data" = nfs "${nas}/cloud-data-dump/user-data";
    "/homelab/nfs/copyparty/user-photos" = nfs "${nas}/cloud-data-dump/user-photos";
    "/homelab/nfs/copyparty/chaosbox" = nfs "${nas}/cloud-data-dump/chaosbox";
    "/homelab/nfs/copyparty/linux-isos" = nfs "${nas}/Linux_Isos";
  };
in
{
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  # replaces the compose "volumes:" block
  fileSystems = mounts;

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
      xff-src = "lan";
      idp-h-usr = "X-Forwarded-User";
      idp-h-grp = "X-Forwarded-Groups";
      auth-ord = "idp,pw,ipu";
      idp-login = "https://fs.javamurray.com/oauth2/start";
      idp-login-t = "Login with authentik.javamurray.com";
      idp-logout = "https://fs.javamurray.com/oauth2/sign_out";
    };

    volumes = {
      "/" = {
        path = "/homelab/copyparty/root";
        access = { r = "@acct"; a = "Java"; };
        flags.dots = true;
      };
      "/\${u}/" = {
        path = "/homelab/nfs/copyparty/user-data/\${u}";
        access = { rwmd = "\${u}"; a = "Java"; };
        flags = { dots = true; e2dsa = true; e2ts = true; };
      };
      "/chaosbox" = {
        path = "/homelab/nfs/copyparty/chaosbox";
        access = { rwmd = "@acct"; a = "Java"; };
        flags.dots = true;
      };
      "/immich-data" = {
        path = "/homelab/nfs/copyparty/user-photos";
        access.r = "Java";
        flags.dots = true;
      };
      "/google-drive" = {
        path = "/mnt/google-drive";
        access.r = "Java";
        flags.dots = true;
      };
      "/linuxisos-audio-book" = {
        path = "/homelab/nfs/copyparty/linux-isos/audio_books";
        access.rwd = "Java";
        flags.dots = true;
      };
      "/linux-isos" = {
        path = "/homelab/nfs/copyparty/linux-isos";
        access.rwd = "Java";
        flags.dots = true;
      };
    };
  };

  systemd.services.copyparty = {
    # wait for NFS before starting
    unitConfig.RequiresMountsFor = builtins.attrNames mounts;
    # the module skips ${u} volumes when sandboxing, so bind the parent by hand
    serviceConfig.BindPaths = [ "/homelab/nfs/copyparty/user-data" ];
  };

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
      entryPoints = [ "https-external" ]; # match your other native routers
      tls = { };
      service = "copyparty";
    };
    services.copyparty.loadBalancer.servers = [ { url = "http://127.0.0.1:4180"; } ];
  };
}