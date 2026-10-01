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

    # Same /var/lib/jellyfin trap as metadataPath below: this defaults there
    # regardless of dataDir, jellyfin (uid 991) can't create anything under
    # root-owned /var/lib, and jellyfin-init's backup step crashes on it
    # right after every migration run — which is what was forcing a crash
    # loop stuck in the --nowebclient migration phase (hence the API/Swagger
    # redirect instead of the actual web client).
    backupDir = "/homelab/jellyfin/backups";

    # replaces the hand-rolled network.xml: nix is now the source of truth
    network = {
      internalHttpPort = 2402;
      localNetworkAddresses = [ "127.0.0.1" ];
      knownProxies = [ "127.0.0.1" ];
      localNetworkSubnets = [ "10.10.1.0/24" ];
    };

    system = {
      # Module defaults this to /var/lib/jellyfin/metadata regardless of
      # dataDir above — jellyfin (uid 991) can't create that under
      # root-owned /var/lib, and the unit has no StateDirectory= to do it
      # for it, so startup crashes with UnauthorizedAccessException. Keep it
      # under the same tree as everything else on this host.
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
      pathInfos = [ "/homelab/nfs" ];
    };
    libraries.Shows = {
      automaticallyAddToCollection = true;
      contentType = "tvshows";
      pathInfos = [ "/homelab/nfs" ];
    };
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
