{
  services.traefik.dynamicConfigOptions.http.middlewares = {
    # https://github.com/goauthentik/authentik/issues/2366
    middlewares-authentik.forwardAuth = {
      address = "http://127.0.0.1:9000/outpost.goauthentik.io/auth/traefik";
      trustForwardHeader = true;
      authResponseHeaders = [
        "X-authentik-username"
        "X-authentik-groups"
        "X-authentik-email"
        "X-authentik-name"
        "X-authentik-uid"
        "X-authentik-jwt"
        "X-authentik-meta-jwks"
        "X-authentik-meta-outpost"
        "X-authentik-meta-provider"
        "X-authentik-meta-app"
        "X-authentik-meta-version"
      ];
    };

    middlewares-rate-limit.rateLimit = {
      average = 100;
      burst = 50;
    };

    # was referenced by chain-no-auth but never defined
    middlewares-compress.compress = { };

    chain-no-auth.chain.middlewares = [
      "middlewares-rate-limit"
      "middlewares-compress"
    ];

    docsarg-redirect.redirectRegex = {
      regex = "^https?://docs-arg.javamurray.com/?(.*)";
      replacement = "https://outline.javamurray.com/s/eaf89668-59ed-4c1f-aaa5-89a26a82c497";
      permanent = true;
    };

    immich-upload.buffering = {
      maxRequestBodyBytes = 53687091200;
      memRequestBodyBytes = 209715200;
    };

    # Security headers middleware
    jellyfin-security-headers.headers = {
      # SSL/HTTPS redirects
      sslRedirect = true;
      sslHost = "jelly.javamurray.com";
      sslForceHost = true;

      # Security headers
      stsSeconds = 315360000;
      stsIncludeSubdomains = true;
      stsPreload = true;
      forceSTSHeader = true;
      frameDeny = true;
      contentTypeNosniff = true;

      # Custom headers
      customResponseHeaders = {
        X-Robots-Tag = "noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex";
        X-XSS-Protection = "1; mode=block";
      };

      customFrameOptionsValue = "allow-from https://jelly.javamurray.com";
    };

    # redirect bare domain to www (works for any domain)
    redirect-to-www.redirectRegex = {
      regex = "^https?://([^/.]+\\.[^/.]+)/(.*)";
      replacement = "https://www.\${1}/\${2}";
      permanent = true;
    };
  };
}
