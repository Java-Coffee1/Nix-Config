{
  services.traefik.staticConfigOptions.entryPoints.minecraft.address = ":25565";
  networking.firewall.allowedTCPPorts = [ 25565 ];

  services.traefik.dynamicConfigOptions.tcp = {
    routers = {
      crafty-fmboysmc = {
        entryPoints = [ "minecraft" ];
        rule = "HostSNI(`*`)";
        service = "crafty-fmboysmc";
      };
      jv-java = {
        entryPoints = [ "https-web" ];
        # '' string so the \. in the regex stays a literal backslash
        rule = ''HostSNI(`matrix-test.shelvacu.com`) || HostSNIRegexp(`^[^.]+\.matrix-test\.shelvacu\.com$`) || HostSNI(`consortium.chat`) || HostSNIRegexp(`^[^.]+\.consortium\.chat$`)'';
        tls.passthrough = true;
        service = "jv-java";
      };
      # salwart = {
      #   entryPoints = [ "https-web" ];
      #   rule = "HostSNI(`mail.jv.ax`)";
      #   tls.passthrough = true;
      #   service = "salwart";
      # };
    };

    services = {
      crafty-fmboysmc.loadBalancer.servers = [ { address = "tasks.crafty:25565"; } ];
      jv-java.loadBalancer.servers = [ { address = "10.10.1.160:443"; } ];
      # salwart.loadBalancer.servers = [ { address = "23.130.212.203:443"; } ];
    };
  };
}
