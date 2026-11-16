{ config, ... }:

{

  age.secrets.servarr-env.file = ../../secrets/servarr-env.age;

  nixflix = {
    enable = true;
    config.Paths = {
      DefaultSubscriptionShowPath = "/homelab/nfs/linux-isos/shows";
      DefaultSubscriptionMoviePath = "/homelab/nfs/linux-isos/movies";
      DefaultManualShowPath = "/homelab/nfs/linux-isos/shows";
      DefaultManualMoviePath = "/homelab/nfs/linux-isos/movies";
      TempDownloadPath = "/homelab/nfs/linux-isos/downloads";
      UseTopicForMoviePath = false;
    };
    stateDir = "";

    nginx.enable = true; # I think I don't need this but I am going to keep it on default

    postgress.enable = false;
    sonarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.age.secrets.servarr-env.path;
        };
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."radarr/api_key".path;
        };
      };

    };

    prowlarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."prowlarr/api_key".path;
        };
      };
    };
  };
}
