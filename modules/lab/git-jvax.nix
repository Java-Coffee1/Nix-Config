{ ... }:

{
  services.gitea = {
    enable = true;
    database.type = "mysql";
    #settings.service.DISABLE_REGISTRATION = true;
  };
}
