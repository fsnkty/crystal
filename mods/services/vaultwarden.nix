{ config, lib, ... }: {
  options.service.web.vaultwarden = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.vaultwarden {
    age.secrets.vault_env = {
      file = ../../shhh/vault_env.age;
      owner = "vaultwarden";
    };
    services = {
      vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "https://vault.${config.service.web.domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = 8222;
          ROCKET_LOG = "critical";
          SMTP_HOST = "mail.${config.service.web.domain}";
          SMPT_PORT = 465;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "vault@${config.service.web.domain}";
          SMTP_FROM_NAME =
            "vault.${config.service.web.domain} Vaultwarden server";
          SMTP_USERNAME = "vault@${config.service.web.domain}";
        };
        environmentFile = config.age.secrets.vault_env.path;
      };
      nginx.virtualHosts."vault.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8222";
          extraConfig = "proxy_pass_header Authorization;";
        };
      };
    };
  };
}
