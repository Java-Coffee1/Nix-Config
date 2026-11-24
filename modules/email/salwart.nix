{ config, ... }:

let
  mailDomains = [
    "javamurray.com"
    "jv.ax"
  ];
  hostname = "mail.${builtins.head mailDomains}";
  oidcUserinfo = "https://auth.jv.ax/application/o/userinfo/";
in
{
  services.stalwart = {
    enable = true;
    stateVersion = config.system.stateVersion;

    openFirewall = true;

    settings = {
      server.hostname = hostname;

      directory."authentik" = {
        type = "oidc";
        timeout = "2s";
        endpoint.url = oidcUserinfo;
        endpoint.method = "userinfo";
        fields.email = "email";
        fields.username = "preferred_username";
        fields.full-name = "name";
      };

      storage.directory = "authentik";
      certificate."default" = {
        cert = "%{file:${config.security.acme.certs.${hostname}.directory}/fullchain.pem}%";
        private-key = "%{file:${config.security.acme.certs.${hostname}.directory}/key.pem}%";
      };

      server.tls = {
        enable = true;
        certificate = "default";
        implicit = false;
      };

      server.listener = {
        smtp = {
          bind = [ "[::]:25" ];
          protocol = "smtp";
        };
        submission = {
          bind = [ "[::]:587" ];
          protocol = "smtp";
        };
        submissions = {
          bind = [ "[::]:465" ];
          protocol = "smtp";
          tls.implicit = true;
        };
        imap = {
          bind = [ "[::]:143" ];
          protocol = "imap";
        };
        imaps = {
          bind = [ "[::]:993" ];
          protocol = "imap";
          tls.implicit = true;
        };
        # webadmin UI + JMAP
        https = {
          bind = [ "[::]:443" ];
          protocol = "http";
          tls.implicit = true;
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "julianmurray4152@gmail.com"; # same contact traefik.nix uses
  security.acme.certs.${hostname} = {
    listenHTTP = ":80";
    group = config.services.stalwart.group;
    reloadServices = [ "stalwart.service" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
