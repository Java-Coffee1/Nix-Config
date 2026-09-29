{ inputs, ... }:

let
  domain = "jelly.jv.ax";
in
{
  imports = [ inputs.declarative-jellyfin.nixosModules.default ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  # systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD"; GPU THING I WILL DO THIS Latter
  # environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  hardware.graphics = {
    enable = true;

    # extraPackages = with pkgs;[
    #   intel-vaapi-driver
    #   libva-vdpau-driver
    # ];
    # set when I add this in
  };

  services.declarative-jellyfin = {
    enable = true;
    dataDir = "/homelab/jellyfin";
    cacheDir = "/homelab/jellyfin/cache";
    # configDir and logDir default to dataDir/config and dataDir/log

    # replaces the hand-rolled network.xml: nix is now the source of truth
    network = {
      internalHttpPort = 2402;
      localNetworkAddresses = [ "127.0.0.1" ];
      knownProxies = [ "127.0.0.1" ];
      localNetworkSubnets = [ "10.10.1.0/24" ];
    };

    system = {
      serverName = "media-dumpsterfire";
      corsHosts = [ domain ];
      activityLogRetentionDays = 3650;
      libraryMetadataRefreshConcurrency = 2;
      libraryScanFanoutConcurrency = 2;
      logFileRetentionDays = 3650;
      parallelImageEncodingLimit = 2;
      pluginRepositories = [
        {
          content.Name = "Jellyfin SSO";
          content.Url = "https://raw.githubusercontent.com/Buco7854/jellyfin-plugin-sso/blob/manifest-release/manifest.json";
          tag = "RepositoryInfo";
        }
      ];
    };

    libraries.Movies = {
      automaticallyAddToCollection = true;
      contentType = "movies";
      pathInfos = [ "/homelab/nfs" ];
    };
    libraries.Shows = {
      automaticallyAddToCollection = true;
      contentType = "tvshows";
      pathInfos = [ "/homelab/nfs" ];
    };

    # --- Authentik SSO login button -------------------------------------
    # declarative-jellyfin can only manage the plugin *repository* above, not
    # a plugin's own settings (not supported upstream yet), so the actual
    # OIDC provider wiring for the "SSO Auth" plugin has to happen by hand
    # in the Jellyfin dashboard after this ships:
    #   1. Dashboard > Plugins > Catalog > install "SSO Auth" (repo added
    #      above), then restart jellyfin.
    #   2. In Authentik: create an OAuth2/OpenID Provider + Application for
    #      Jellyfin. Redirect URI: https://${domain}/sso/OID/redirect/authentik
    #   3. Dashboard > Plugins > SSO-Auth > Add a new provider named
    #      "authentik" and paste in:
    #        OID Endpoint:   <PASTE Authentik issuer URL here, e.g.
    #                         https://auth.javamurray.com/application/o/<slug>/>
    #        Client ID:      <PASTE FROM AUTHENTIK>
    #        Client Secret:  <PASTE FROM AUTHENTIK>
    #      then tick "Enabled" and set up role/admin claim mapping as wanted.
    branding.loginDisclaimer = ''
      <form action="/sso/OID/start/authentik">
        <button class="raised block emby-button button-submit">
          Sign in with Authentik
        </button>
      </form>
    '';
    branding.customCss = ''
      a.raised.emby-button {
        padding: 0.9em 1em;
        color: inherit !important;
      }

      .disclaimerContainer {
        display: block;
      }
    '';
  };

  services.traefik.dynamicConfigOptions = {
    http.routers.jellyfin = {
      rule = "Host(`${domain}`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      tls.certResolver = "letsencrypt";
    };
    http.services.jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:2402"; } ];
  };
}
