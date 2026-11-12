{ ... }:

{
  nixflix = {
    enable = true;
    mediaDir = "javi/set/this/later";
    stateDir = "javi/set/this/later";

    postgres.enable = true;

    sonarr = {
      enable = true;
      config = {
        apiKey = { };
        hostConfig.password = { };
      }; # end of config

    }; # end of sonarr

    radarr = {
      enable = true;
      config = {
        apiKey = { };
        hostConfig.password = { };
      };
    }; # end of radarr
  }; # end of nixflix

  services.sabnzbd = {
    enable = true;
    settings = {
      misc.api_key = { };
    };
  };
}
