{
  config,
  lib,
  nuke,
  inputs,
  modulesPath,
  ...
}:
let
  cfg = config.service.web.vaultwarden;
  inherit (config.networking) domain;
  inherit (lib) mkIf;
in
{
  # awaiting pr https://github.com/NixOS/nixpkgs/pull/292485
  disabledModules = [ "${modulesPath}/services/security/vaultwarden/default.nix" ];
  imports = [ "${inputs.vault}/nixos/modules/services/security/vaultwarden/default.nix" ];

  options.service.web.vaultwarden = nuke.mkWebOpt 8092;
  config = mkIf cfg.enable {
    age.secrets.vault_env = {
      file = ../../shhh/vault_env.age;
      owner = "vaultwarden";
    };
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vault.${domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_PORT = cfg.port;
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
