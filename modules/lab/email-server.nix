{ config, ... }: {
  age.secrets.cf-smtp.file = ../../secrets/cf-smtp.age;
  services.postfix = {
    enable = true;
    settings.main = {
      mynetworks = [
        "127.0.0.0/8"
        "10.10.1.0/24"
      ];
      relayhost = [ "[smtp.mx.cloudflare.net]:465" ];
      message_size_limit = 5242880;

      smtp_tls_security_level = "encrypt";
      smtp_tls_wrappermode = true;

      smtp_sasl_auth_enable = true;
      smtp_sasl_security_options = "noanonymous";
      smtp_sasl_password_maps = "texthash:${config.age.secrets.cf-smtp.path}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 25 ];
}
