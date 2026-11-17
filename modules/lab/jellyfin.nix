{ inputs, pkgs, ... }:

let
  domain = "jelly.jv.ax";
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

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
  };

  services.declarative-jellyfin = {
    package = unstable.jellyfin;
    enable = true;
    dataDir = "/homelab/jellyfin";
    cacheDir = "/homelab/jellyfin/cache";
    # configDir and logDir default to dataDir/config and dataDir/log

    users.nixadmin = {
      hashedPassword = "$PBKDF2-SHA512$iterations=210000$B2BDC0291028CBC8004AC8A5C8A898C1$2D6F7BCAF6ED78503BCED22BA28E7BA0AEA46EE5E8AD45C14D2B00DF6E65AD830E7159535FA3F9FBA22E2D5A8CB7EDCE3AE9B39EB0AF1F4EC34E55AA2BD687FC";
      permissions = {
        isAdministrator = true;
        isHidden = true;
      };
    };

    backupDir = "/homelab/jellyfin/backups";

    # replaces the hand-rolled network.xml: nix is now the source of truth
    network = {
      internalHttpPort = 2402;
      localNetworkAddresses = [ "127.0.0.1" ];
      knownProxies = [ "127.0.0.1" ];
      localNetworkSubnets = [ "10.10.1.0/24" ];
    };

    system = {
      metadataPath = "/homelab/jellyfin/metadata";
      serverName = "media-dumpsterfire";
      corsHosts = [ domain ];
      activityLogRetentionDays = 3650;
      libraryMetadataRefreshConcurrency = 2;
      libraryScanFanoutConcurrency = 2;
      logFileRetentionDays = 3650;
      parallelImageEncodingLimit = 2;
    };

    libraries.Movies = {
      automaticallyAddToCollection = true;
      contentType = "movies";
      pathInfos = [ "/homelab/nfs/linux-isos/movies" ];
    };
    libraries.Shows = {
      automaticallyAddToCollection = true;
      contentType = "tvshows";
      pathInfos = [ "/homelab/nfs/linux-isos/shows" ];
    };
    libraries.Audio-Books = {
      automaticallyAddToCollection = true;
      contentType = "tvshows";
      pathInfos = [ "/homelab/nfs/linux-isos/audio_books" ];
    };
  };

  services.traefik.dynamicConfigOptions = {
    http.routers.jellyfin = {
      rule = "Host(`jelly.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      tls.certResolver = "letsencrypt";
    };
    http.routers.jellyfin-old = {
      rule = "Host(`jelly.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      middlewares = [ "jellyfin-redirect" ];
      tls.certResolver = "letsencrypt";
    };
    http.routers.jellyfin-old2 = {
      rule = "Host(`j.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      middlewares = [ "jellyfin-redirect" ];
      tls.certResolver = "letsencrypt";
    };
    http.middlewares.jellyfin-redirect.redirectRegex = {
      regex = "^https://[^/]+/(.*)";
      replacement = "https://jelly.jv.ax/\${1}";
      permanent = true;
    };
    http.services.jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:2402"; } ];
  };
}
