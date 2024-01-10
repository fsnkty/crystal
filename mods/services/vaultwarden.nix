{
  config,
  lib,
  ...
}: {
  options.local.services.web.vaultwarden.enable = lib.mkEnableOption "";
  config = let
    domain = "vault.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.vaultwarden.enable {
      age.secrets.vault_env = {
        file = ../../shhh/vault_env.age;
        owner = "vaultwarden";
      };
      services = {
        vaultwarden = {
          enable = true;
          config = {
            DOMAIN = "https://${domain}";
            SIGNUPS_ALLOWED = false;
            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = 8222;
            ROCKET_LOG = "critical";
            SMTP_HOST = "mail.nuko.city";
            SMPT_PORT = 465;
            SMTP_SECURITY = "starttls";
            SMTP_FROM = "vault@nuko.city";
            SMTP_FROM_NAME = "vault.nuko.city Vaultwarden server";
            SMTP_USERNAME = "vault@nuko.city";
          };
          environmentFile = config.age.secrets.vault_env.path;
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
            extraConfig = "proxy_pass_header Authorization;";
          };
        };
      };
    };
}
