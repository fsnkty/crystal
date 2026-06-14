{
  config,
  lib,
  ...
}:
{
  options.crystal.server.vaultwarden.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.vaultwarden.enable {
    services = {
      nginx.virtualHosts."vault.shimeji.cafe" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
          proxyWebsockets = true;
        };
      };
      vaultwarden = {
        enable = true;
        environmentFile = "/keys/vaultwarden";
        domain = "vault.shimeji.cafe";
        config = {
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = 8095;
          ROCKET_LOG = "critical";
        };
      };
    };
  };
}