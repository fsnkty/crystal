{
  config,
  lib,
  nuke,
  inputs,
  modulesPath,
  ...
}:
{
  disabledModules = [ "${modulesPath}/services/security/vaultwarden/default.nix" ];
  imports = [ "${inputs.vault}/nixos/modules/services/security/vaultwarden/default.nix" ];
  options.service.web.vaultwarden = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8092;
  };
  config = lib.mkIf config.service.web.vaultwarden.enable {
    age.secrets.vault_env = {
      file = ../../shhh/vault_env.age;
      owner = "vaultwarden";
    };
    services.vaultwarden = {
      enable = true;
      config =
        let
          inherit (config.networking) domain;
        in
        {
          DOMAIN = "https://vault.${domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = config.service.web.vaultwarden.port;
          ROCKET_LOG = "critical";
          SMTP_HOST = "mail.${domain}";
          SMPT_PORT = 465;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "vault@${domain}";
          SMTP_FROM_NAME = "vault.${domain} Vaultwarden server";
          SMTP_USERNAME = "vault@${domain}";
        };
      environmentFile = config.age.secrets.vault_env.path;
    };
  };
}
