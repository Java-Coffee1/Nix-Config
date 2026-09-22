{ lib, ... }:

let
  # one router + one service per app
  mkApp =
    name:
    {
      host,
      url,
      middlewares ? [ ],
    }:
    {
      http.routers.${name} = {
        rule = "Host(`${host}`)";
        entryPoints = [ "https-web" ];
        service = name;
        inherit middlewares;
        tls.certResolver = "letsencrypt";
      };
      http.services.${name}.loadBalancer.servers = [ { inherit url; } ];
    };

  authentik = [ "middlewares-authentik" ];
in
{
  services.traefik.dynamicConfigOptions = lib.mkMerge [
    (mkApp "authentik" {
      host = "auth.javamurray.com";
      url = "http://10.10.1.150:9000";
    })
    (mkApp "authentik-redirect" {
      host = "authentik.javamurray.com";
      url = "http://127.0.0.1"; # noop, the redirect middleware answers
      middlewares = [ "redirect-to-new" ];
    })
    {
      http.middlewares.redirect-to-new.redirectRegex = {
        regex = "^https?://authentik\\.javamurray\\.com/(.*)";
        replacement = "https://auth.javamurray.com/\${1}";
        permanent = true;
      };
    }
    (mkApp "outline" {
      host = "outline.javamurray.com";
      url = "http://10.10.1.150:4000";
    })
    {
      http.routers.traefik-dashboard = {
        rule = "Host(`traefik.jv.ax`)";
        entryPoints = [ "https-web" ];
        service = "api@internal";
        middlewares = authentik;
        tls.certResolver = "letsencrypt";
      };
    }
    # (mkApp "copy-party" {
    #   host = "fs.javamurray.com";
    #   url = "http://oauth2-proxy:4180";
    # })
    # (mkApp "planka" {
    #   host = "kanban.javamurray.com";
    #   url = "http://planka:1337";
    # })
    # (mkApp "immich" {
    #   host = "photos.javamurray.com";
    #   url = "http://immich-server:2283";
    #   middlewares = [ "immich-upload" ];
    # })
    # (mkApp "openwebui" {
    #   host = "ai.javamurray.com";
    #   url = "http://open-webui:8080";
    # })
    # (mkApp "docsarg" {
    #   host = "docs-arg.javamurray.com";
    #   url = "http://127.0.0.1"; # noop, the redirect middleware answers
    #   middlewares = [ "docsarg-redirect" ];
    # })
    # (mkApp "ConvertX" {
    #   host = "convert.javamurray.com";
    #   url = "http://convertx:3000";
    # })
    # (mkApp "Metube" {
    #   host = "ytdl.javamurray.com";
    #   url = "http://metube:8081";
    # })
    # (mkApp "homepage" {
    #   host = "home.javamurray.com";
    #   url = "http://homepage:3000";
    #   middlewares = authentik;
    # })
    (mkApp "sonarr" {
      host = "sonarr.javamurray.com";
      url = "http://10.10.1.107:8989";
      middlewares = authentik;
    })
    (mkApp "radarr" {
      host = "radarr.javamurray.com";
      url = "http://10.10.1.107:7878";
      middlewares = authentik;
    })
    (mkApp "qbittorrent" {
      host = "qbit.javamurray.com";
      url = "http://10.10.1.107:8085";
      middlewares = authentik;
    })
    (mkApp "Immich" {
      host = "photos.javamurray.com";
      url = "http://10.10.1.150:2283";
    })
    # (mkApp "Mainsail" {
    #   host = "mainsail.javamurray.com";
    #   url = "http://10.25.25.99:80";
    #   middlewares = authentik;
    # })
    # (mkApp "ArchiveBox" {
    #   host = "archive.javamurray.com";
    #   url = "http://archivebox:8000";
    #   middlewares = authentik;
    # })
  ];
}
