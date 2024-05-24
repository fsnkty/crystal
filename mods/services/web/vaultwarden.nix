{
  modulesPath,
  inputs,
  config,
  _lib,
  lib,
  ...
}:
{
  # awaiting 292485
  disabledModules = [ "${modulesPath}/services/security/vaultwarden/default.nix" ];
  imports = [ "${inputs.vault}/nixos/modules/services/security/vaultwarden/default.nix" ];

  options._services.web.vaultwarden = _lib.mkWebOpt "vault" 8092;
  config =
    let
      inherit (config._services.web.vaultwarden) port enable;
    in
    lib.mkIf enable {
      assertions = _lib.assertWeb;
      services.vaultwarden = {
        inherit enable;
        config = {
          DOMAIN = "https://vault.${config.networking.domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = port;
          ROCKET_LOG = "critical";
        };
      };
    };
}
