{ config, lib, ... }: {
  age.secrets.smtp.file = ../../secrets/mailjet_email_token.age;
  services.postfix = {
    enable = true;
    settings.master.smtp_inet.name = lib.mkForce "2525";
    settings.main = {
      mynetworks = [
        "127.0.0.0/8"
        "10.10.1.0/24"
        "10.25.25.101/32"
        "10.30.30.101/32"
        # "10.25.25.138/32"
      ];
      relayhost = [ "[in-v3.mailjet.com]:465" ];
      message_size_limit = 5242880;

      smtp_tls_security_level = "encrypt";
      smtp_tls_wrappermode = true;

      smtp_sasl_auth_enable = true;
      smtp_sasl_security_options = "noanonymous";
      smtp_sasl_password_maps = "texthash:${config.age.secrets.smtp.path}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 2525 ];
}
