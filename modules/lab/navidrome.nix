{ config, ... }:

{
  age.secrets.navidrome-lastfm-env.file = ../../secrets/navidrome-lastfm-env.age;

  services.navidrome = {
    enable = true;
    environmentFile = config.age.secrets.navidrome-lastfm-env.path;
    settings = {
      Address = "127.0.0.1";
      Port = 4533;

      MusicFolder = "/homelab/nfs/linux-isos/music";
      DataFolder = "/homelab/navidrome/data";
      CacheFolder = "/homelab/navidrome/cache";
      ExtAuth.UserHeader = "X-authentik-username";
      ExtAuth.TrustedSources = "127.0.0.1/32";

      # ApiKey/Secret come from environmentFile (ND_LASTFM_APIKEY / ND_LASTFM_SECRET)
      LastFM.Enabled = true;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    # Navidrome trusts X-authentik-username from 127.0.0.1 (ExtAuth.TrustedSources),
    # which is only safe as long as a client can never set that header itself.
    # /rest/* skips middlewares-authentik (Subsonic clients can't do the login
    # redirect), so without this it'd be a free pick-any-username login bypass.
    middlewares.navidrome-strip-authentik-headers.headers.customRequestHeaders = {
      "X-authentik-username" = "";
      "X-authentik-groups" = "";
      "X-authentik-email" = "";
      "X-authentik-name" = "";
      "X-authentik-uid" = "";
      "X-authentik-jwt" = "";
      "X-authentik-meta-jwks" = "";
      "X-authentik-meta-outpost" = "";
      "X-authentik-meta-provider" = "";
      "X-authentik-meta-app" = "";
      "X-authentik-meta-version" = "";
    };
    routers.navidrome-rest = {
      rule = "Host(`music.jv.ax`) && PathPrefix(`/rest/`)";
      entryPoints = [ "https-web" ];
      service = "navidrome";
      middlewares = [ "navidrome-strip-authentik-headers" ];
      priority = 1000;
      tls.certResolver = "letsencrypt";
    };
    routers.navidrome = {
      rule = "Host(`music.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "navidrome";
      # strip first, so only middlewares-authentik's own injected values survive
      middlewares = [
        "navidrome-strip-authentik-headers"
        "middlewares-authentik"
      ];
      tls.certResolver = "letsencrypt";
    };
    routers.navidrome-m = {
      rule = "Host(`m.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "navidrome";
      middlewares = [ "navidrome-redirect" ];
      tls.certResolver = "letsencrypt";
    };
    middlewares.navidrome-redirect.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://music.jv.ax/\${1}";
      permanent = true;
    };
    services.navidrome.loadBalancer.servers = [ { url = "http://127.0.0.1:4533"; } ];
  };
}