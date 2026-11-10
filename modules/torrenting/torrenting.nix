{ ... }:

{
  nixflix = {
    enable = true;
    mediaDir = "javi/set/this/latter";
    stateDir = "javi/set/this/latter";

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
    }; # end of raddar
  }; # end of nixflix

  services.sabnzbd = {
    enable = true;
    settings = {
      misc.api_key = { };
    };
  };
}
