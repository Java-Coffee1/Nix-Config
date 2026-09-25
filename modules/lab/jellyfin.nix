{ config, pkgs, ... }:

{
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

  services.jellyfin = {
    enable = true;
    dataDir = "/homelab/jellyfin";
    cacheDir = "/homelab/jellyfin/cache";
    # configDir and logDir default to dataDir/config and dataDir/log
    # web gui port + bind address set declaratively in network.xml below
  };

  services.traefik.dynamicConfigOptions = {
    http.routers.jellyfin = {
      rule = "Host(`jelly.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "jellyfin";
      tls.certResolver = "letsencrypt";
    };
    http.services.jellyfin.loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];
  };
}
