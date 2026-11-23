# config options: https://docs.gitea.com/administration/config-cheat-sheet/
{ config, lib, pkgs, ... }:

let
  # https://github.com/lutinglt/gitea-github-theme
  githubThemeCss = pkgs.runCommand "gitea-github-theme-css" {
    src = pkgs.fetchurl {
      url = "https://github.com/lutinglt/gitea-github-theme/releases/download/v28.4.0/theme-github-base.tar.gz";
      sha256 = "sha256-cSEBRIcc50uvJUWG4Xji9+Y+UPxH2RopexkdsHHn+/0=";
    };
  } ''
    mkdir -p $out
    tar -xzf $src -C $out --strip-components=1
  '';
  githubThemeVariants = [ "github-auto" "github-light" "github-dark" "github-soft-dark" ];

  giteaRobotsTxt = pkgs.writeText "gitea-robots.txt" ''
    User-agent: *
    Disallow: /
  '';
  blockedBotUserAgents = [
    "nikto" "nmap" "masscan" "sqlmap" "nuclei" "zgrab" "gobuster" "dirbuster" "wpscan" "acunetix" "nessus"
    "GPTBot" "ChatGPT-User" "ClaudeBot" "Claude-Web" "anthropic-ai" "CCBot" "Bytespider" "PetalBot"
    "AhrefsBot" "SemrushBot" "MJ12bot" "DotBot" "Amazonbot" "Applebot-Extended" "Google-Extended"
    "Diffbot" "FacebookBot" "ImagesiftBot" "Meta-ExternalAgent"
  ];
in
{
  age.secrets.gitea-env = {
    file = ../../secrets/homelab-nixos-btw/gitea-env.age;
    owner = "gitea";
  };

  services.gitea = {
    enable = true;
    stateDir = "/homelab/gitea";

    # hand-made db, over the unix socket (peer auth) — same as outline/gitlab.
    # create it yourself once: `sudo -u postgres createuser gitea && sudo -u postgres createdb -O gitea gitea_db`
    database = {
      type = "postgres";
      createDatabase = false;
      name = "gitea_db";
      user = "gitea";
      socket = "/run/postgresql";
    };

    settings = {
      server = {
        DOMAIN = "git.jv.ax";
        ROOT_URL = "https://git.jv.ax/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3001;
      };
      service.DISABLE_REGISTRATION = true; # sign in via Authentik OIDC instead
      service.ENABLE_PASSWORD_SIGNIN_FORM = false; # hide local login form, SSO button only
      service.REQUIRE_SIGNIN_VIEW = "expensive"; # Gitea 1.23+; login only for heavy pages (blame/archives/raw), rest stays public/indexable
      repository.DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true; # kills the 274MB tarball endpoint
      oauth2_client.ENABLE_AUTO_REGISTRATION = true;
      oauth2_client.USERNAME = "preferred_username";
      ui = {
        THEMES = lib.concatStringsSep "," ([ "gitea-auto" "gitea-light" "gitea-dark" ] ++ githubThemeVariants);
        DEFAULT_THEME = "github-dark";
      };
      "git.timeout".MIGRATE = 3600;
    };
  };

  systemd.services.gitea = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/gitea".d = {
    user = "gitea";
    group = "gitea";
    mode = "750";
  };

  systemd.tmpfiles.rules =
    let
      cssDir = "${config.services.gitea.customDir}/public/assets/css";
    in
    [
      "d ${config.services.gitea.customDir}/public 0750 gitea gitea -"
      "d ${config.services.gitea.customDir}/public/assets 0750 gitea gitea -"
      "d ${cssDir} 0750 gitea gitea -"
      "L+ ${config.services.gitea.customDir}/public/robots.txt - - - - ${giteaRobotsTxt}"
    ]
    ++ map
      (name: "L+ ${cssDir}/theme-${name}.css - - - - ${githubThemeCss}/theme-${name}.css")
      githubThemeVariants;

  systemd.services.gitea-oidc-setup = {
    description = "Register Authentik as a Gitea OAuth2 auth source";
    after = [ "gitea.service" ];
    wantedBy = [ "gitea.service" ];
    path = [ pkgs.gawk ];
    environment = {
      GITEA_WORK_DIR = config.services.gitea.stateDir;
      GITEA_CUSTOM = config.services.gitea.customDir;
      HOME = config.services.gitea.stateDir;
    };
    serviceConfig = {
      Type = "oneshot";
      User = config.services.gitea.user;
      WorkingDirectory = config.services.gitea.stateDir;
      EnvironmentFile = config.age.secrets.gitea-env.path;
    };
    script = ''
      set -u
      existing_id=$(${lib.getExe config.services.gitea.package} admin auth list --vertical-bars 2>/dev/null \
        | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2)} $2=="Authentik" {gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1; exit}')

      auth_args=(
        --name Authentik
        --provider openidConnect
        --key "$GITEA_OIDC_CLIENT_ID"
        --secret "$GITEA_OIDC_CLIENT_SECRET"
        # "git" here is the Authentik application *slug* — update it if
        # you name the Authentik application/provider something else.
        --auto-discover-url "https://auth.javamurray.com/application/o/git/.well-known/openid-configuration"
        --scopes "openid email profile groups"
        --group-claim-name "git"
        --admin-group "Admin"
      )

      if [ -n "$existing_id" ]; then
        ${lib.getExe config.services.gitea.package} admin auth update-oauth --id "$existing_id" "''${auth_args[@]}"
      else
        ${lib.getExe config.services.gitea.package} admin auth add-oauth "''${auth_args[@]}"
      fi
    '';
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.gitea = {
      rule = "Host(`${config.services.gitea.settings.server.DOMAIN}`) && !HeaderRegexp(`User-Agent`, `(?i)(${lib.concatStringsSep "|" blockedBotUserAgents})`)";
      entryPoints = [ "https-web" ];
      service = "gitea";
      tls.certResolver = "letsencrypt";
    };
    services.gitea.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}"; }
    ];
  };
}
