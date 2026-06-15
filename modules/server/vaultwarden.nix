{
  config,
  lib,
  ...
}:
{
  options.crystal.server.vaultwarden.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.vaultwarden.enable {
    services = {
      vaultwarden = {
        enable = true;
        # when not set, admin panel is disabled.
        #environmentFile = "/keys/vaultwarden";
        domain = "vault.shimeji.cafe";
        config = {
          DOMAIN = "https://vault.shimeji.cafe";

          
          SENDS_ALLOWED = false;
          SIGNUPS_ALLOWED = false;
          ORG_CREATION_USERS = "none";
          INVITATIONS_ALLOWED = false;
          
          PASSWORD_HINTS_ALLOWED = false;
          
          # reduces risk of determining cached icons
          ICON_SERVICE = "duckduckgo";
          # reduces local risk surface
          HTTP_REQUEST_BLOCK_NON_GLOBAL_IPS = true;
          
          EXTENDED_LOGGING = true;
          
          # stricter than defaults, 60 & 10
          LOGIN_RATE_LIMIT_SECONDS = 30;
          LOGIN_RATELIMIT_MAX_BURST = 4;
          
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8095;
        };
      };
      nginx.virtualHosts."vault.shimeji.cafe" = {
        useACMEHost = "shimeji.cafe";
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8095";
      };
    };
  };
}