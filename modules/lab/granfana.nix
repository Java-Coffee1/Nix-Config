{ config, ... }:

{
  age.secrets.grafana-secret-key = {
    file = ../../secrets/grafana-secret-key.age;
    owner = "grafana";
  };
  age.secrets.grafana-oidc-secret = {
    file = ../../secrets/grafana-oidc-secret.age;
    owner = "grafana";
  };

  environment.etc."grafana-dashboards".source = "/homelab/granfana/dashboards";
  services.grafana = {
    enable = true;
    dataDir = "/homelab/granfana";
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3232;
        enforce_domain = true;
        enable_gzip = true;
        domain = "gf.jv.ax";
        root_url = "https://gf.jv.ax/";
      }; # end of server
      security.secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
      users.allow_sign_up = false;
      analytics.reporting_enabled = false;
      # 2. OIDC (Generic OAuth) Configuration
      "auth.generic_oauth" = {
        enabled = true;
        name = "authentik";
        allow_sign_up = true;
        client_id = "0yDP5Zxt6PTpRMeF2PSDjrCitBS9FdzafJgi4sui";
        client_secret = "$__file{${config.age.secrets.grafana-oidc-secret.path}}";

        # Scopes required for standard OIDC
        scopes = "openid profile email groups";

        # Identity Provider Endpoints
        auth_url = "https://auth.javamurray.com/application/o/authorize/";
        token_url = "https://auth.javamurray.com/application/o/token/";
        api_url = "https://auth.javamurray.com/application/o/userinfo/";

        # Token Validation & Security
        use_pkce = true;
        validate_id_token = true;

        # Attribute Mapping (JMESPath expressions)
        email_attribute_path = "email";
        login_attribute_path = "preferred_username";
        name_attribute_path = "name";

        # Role mapping from OIDC claims to Grafana Admin/Editor/Viewer roles
        role_attribute_path = "contains(groups[*], 'grafana-admins') && 'Admin' || contains(groups[*], 'grafana-editors') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          editable = false;
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "homelab";
          disableDeletion = true;
          options = {
            path = "/homelab/granfana/dashboards";
            foldersFromFilesStructure = true;
          };
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "360d";
    stateDir = "prometheus2";
    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
      {
        job_name = "traefik";
        static_configs = [ { targets = [ "127.0.0.1:8083" ]; } ];
      }
    ];
  };

  fileSystems."/var/lib/prometheus2" = {
    device = "/homelab/nfs/data-dumpster/granfana/prometheus";
    fsType = "none";
    options = [ "bind" ];
  };

  systemd.tmpfiles.settings."00-homelab"."/homelab/granfana".d = {
    user = "grafana";
    group = "grafana";
    mode = "755";
  };
  systemd.tmpfiles.settings."00-homelab"."/homelab/granfana/dashboards".d = {
    user = "grafana";
    group = "grafana";
    mode = "755";
  };

  #######################
  ## Traefik
  #######################

  services.traefik.dynamicConfigOptions.http = {
    routers.grafana = {
      rule = "Host(`gf.jv.ax`)";
      entryPoints = [ "https-web" ];
      service = "grafana";
      tls.certResolver = "letsencrypt";
    };
    services.grafana.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}"; }
    ];
  };
}
