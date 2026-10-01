{ inputs, ... }:

let
  domain = "jelly.jv.ax";
  # unstable = import inputs.nixpkgs-unstable {
  #   inherit (pkgs.stdenv.hostPlatform) system;
  #   config.allowUnfree = true;
  # };

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
    # package = unstable.jellyfin;
    enable = true;
    dataDir = "/homelab/jellyfin";
    cacheDir = "/homelab/jellyfin/cache";
    # configDir and logDir default to dataDir/config and dataDir/log

    users.nixadmin = {
      hashedPassword = "$PBKDF2-SHA512$iterations=210000$C5E9E9D8D92FBAF63722CDB3C17656CB$4760E47DC2A82EE670F47741613EB38D322785DD5C79D34EC03C4674295A9EE0AE73D0B57FB39F887EF4D0E043EEC2118AEB50131C54C12D25503014DB628E90";
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
      rule = "Host(`${domain}`) || Host(`jelly.javamurray.com`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      tls.certResolver = "letsencrypt";
    };
    http.services.jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:2402"; } ];
  };
}
