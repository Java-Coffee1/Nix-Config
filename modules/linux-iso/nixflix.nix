{ config, lib, pkgs, inputs, ... }:
let
  nfs-media = "/homelab/nfs/linux-isos";

  # nixflix.seerr requires Seerr >=3.5.0; the pinned nixpkgs (26.05) only has
  # 3.2.0, so pull the package from nixpkgs-unstable instead.
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };

  # type:public Prowlarr indexers (github.com/Prowlarr/Indexers), trimmed to
  # the ones that actually show up as reliable/widely-used in current
  # rankings (TorrentFreak's 2026 most-visited list, *arr-stack indexer
  # guides) - dropping the niche/regional/adult/crack-site long tail.
  # Reachable directly - no Cloudflare challenge in the way.
  publicIndexerNames = [
    "AniSource"
    "Anime Tosho"
    "Bangumi Moe"
    "Internet Archive"
    "LimeTorrents"
    "LinuxTracker"
    "nekoBT"
    "Nipponsei"
    "Nyaa.si"
    "PandaCD"
    "Shana Project"
    # "showRSS" dropped: Prowlarr has TWO schemas both literally named
    # "showRSS" (the real Cardigann one, and an unrelated generic "Torrent
    # RSS Feed" type whose default display name collides with it).
    # nixflix's indexers.nix looks up schemas by display name only, so it
    # always matches both and sends Prowlarr a corrupted two-object request
    # body. Not fixable from our side without patching nixflix itself.
    "The Pirate Bay"
    "Tokyo Toshokan"
    "TorrentDownload"
    "TorrentProject2"
    "YTS"
  ];

  # Same list, but Prowlarr's direct request gets a Cloudflare JS challenge
  # instead of the site - these need to go through the FlareSolverr proxy.
  cloudflareIndexerNames = [
    "1337x"
    "BT.etree"
    "EZTV"
    "kickasstorrents.to"
    "kickasstorrents.ws"
    "Torrent Downloads"
  ];
in
{
  # one file per secret, each holding ONLY the raw value (no KEY=value)
  age.secrets = {
    wg-conf.file = ../../secrets/linux-iso-btw/windscribe-wg.age;
    sonarr-api-key.file = ../../secrets/linux-iso-btw/sonarr-api-key.age;
    radarr-api-key.file = ../../secrets/linux-iso-btw/radarr-api-key.age;
    prowlarr-api-key.file = ../../secrets/linux-iso-btw/prowlarr-api-key.age;
    seerr-api-key.file = ../../secrets/linux-iso-btw/seerr-api-key.age;
    seerr-jellyfin-admin-password.file = ../../secrets/linux-iso-btw/seerr-jellyfin-admin-password.age;
    lidarr-api-key.file = ../../secrets/linux-iso-btw/lidarr-api-key.age;
  };

  nixflix = {
    enable = true;
    mediaDir = nfs-media;
    downloadsDir = "${nfs-media}/downloads";
    stateDir = "/homelab/nixflix";

    nginx.enable = true;

    flaresolverr.enable = true;

    vpn = {
      enable = true;
      wgConfFile = config.age.secrets.wg-conf.path;
      allowedIngress = [ "10.10.1.170/32" ];
    };

    downloadarr.qbittorrent = {
      enable = true;
      host = config.vpnNamespaces.wg.namespaceAddress;
      username = "javi";
      password._secret = config.age.secrets.qbittorrent-password.path;
    };

    sonarr = {
      enable = true;
      mediaDirs = [ "${nfs-media}/shows" ]; 
      config.apiKey._secret = config.age.secrets.sonarr-api-key.path;

      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };

    radarr = {
      enable = true;
      config.apiKey._secret = config.age.secrets.radarr-api-key.path;
      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };

    lidarr = {
      enable = true;
      mediaDirs = [ "${nfs-media}/music" ];
      config.apiKey._secret = config.age.secrets.lidarr-api-key.path;
      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      config.hostConfig.bindAddress = "10.10.1.105";
      openFirewall = true;
    };

    prowlarr = {
      enable = true;
      config.apiKey._secret = config.age.secrets.prowlarr-api-key.path;
      config.hostConfig.username = null;
      config.hostConfig.authenticationMethod = "external";
      # config.hostConfig.bindAddress = "10.10.1.105";
      # openFirewall = true;
      config.indexers =
        (map (name: { inherit name; }) publicIndexerNames)
        ++ (map (name: { inherit name; tags = [ "flaresolverr" ]; }) cloudflareIndexerNames);
    };

    # Radarr/Sonarr wiring is automatic (nixflix derives it from
    # nixflix.radarr/nixflix.sonarr above). Jellyfin is on a separate host
    # (homelab-nixos-btw, not managed by nixflix) and reverse-proxied at
    # jelly.jv.ax, so Seerr talks to it over the same public HTTPS route any
    # other client would use. adminUsername is the declarative local admin
    # account managed in modules/lab/jellyfin.nix (services.declarative-jellyfin.users.nixadmin).
    seerr = {
      enable = true;
      package = unstablePkgs.seerr;
      apiKey._secret = config.age.secrets.seerr-api-key.path;
      openFirewall = true;
      jellyfin = {
        hostname = "jelly.jv.ax";
        port = 443;
        useSsl = true;
        adminUsername = "nixadmin";
        adminPassword._secret = config.age.secrets.seerr-jellyfin-admin-password.path;
      };
      settings.users.defaultPermissions = 160;
    };
  };

  # nixflix doesn't open the peer port for you
  vpnNamespaces.wg.vpn = {
    allowedTCPPorts = [ 51413 ];
    allowedUDPPorts = [ 51413 ];
  };

  # nixflix's lidarr-delayprofiles sends a hardcoded payload using an old
  # Lidarr API shape (an "items" array keyed by protocol) that the installed
  # Lidarr version rejects with HTTP 400 - confirmed by hand against the live
  # API, which expects flat enableUsenet/usenetDelay/torrentDelay fields
  # instead. Lidarr's own shipped default delay profile (immediate grab, no
  # artificial delay) is already correct for a torrent-only setup, so this
  # step was never changing anything real - just disable it rather than
  # have it fail every deploy.
  systemd.services.lidarr-delayprofiles.enable = false;

  # "0.0.0.0" (not the LAN IP specifically) - nixflix's own setup services
  # (seerr-setup, seerr-jellyfin, seerr-libraries, seerr-radarr, seerr-sonarr)
  # all hardcode 127.0.0.1 to talk to Seerr internally via connectionAddress,
  # which doesn't know about this override. Binding to one specific LAN IP
  # breaks those; binding to all interfaces satisfies both that and Traefik.
  systemd.services.seerr.environment.HOST = lib.mkForce "0.0.0.0";

  systemd.services.prowlarr-app-tags = {
    description = "Tag Prowlarr's Radarr/Sonarr applications with flaresolverr so tagged indexers still sync to them";
    after = [
      "prowlarr-tags.service"
      "prowlarr-applications.service"
    ];
    requires = [
      "prowlarr-tags.service"
      "prowlarr-applications.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      API_KEY=$(cat ${config.age.secrets.prowlarr-api-key.path})
      BASE_URL="http://127.0.0.1:9696/api/v1"

      TAG_ID=$(curl -sf -H "X-Api-Key: $API_KEY" "$BASE_URL/tag" \
        | ${pkgs.jq}/bin/jq -r '.[] | select(.label == "flaresolverr") | .id')

      if [ -z "$TAG_ID" ]; then
        echo "flaresolverr tag not found yet, skipping"
        exit 0
      fi

      for APP_ID in $(curl -sf -H "X-Api-Key: $API_KEY" "$BASE_URL/applications" | ${pkgs.jq}/bin/jq -r '.[].id'); do
        APP=$(curl -sf -H "X-Api-Key: $API_KEY" "$BASE_URL/applications/$APP_ID")
        UPDATED=$(echo "$APP" | ${pkgs.jq}/bin/jq --argjson tagId "$TAG_ID" '.tags = ((.tags + [$tagId]) | unique)')
        curl -sf -X PUT -H "X-Api-Key: $API_KEY" -H "Content-Type: application/json" \
          -d "$UPDATED" "$BASE_URL/applications/$APP_ID" >/dev/null
        echo "Tagged application $APP_ID with flaresolverr tag"
      done
    '';
  };
}
