{ config, lib, ... }:
{
  options.service.web.forgejo = lib.mkEnableOption "";
  config =
    let
      domain = "tea.${config.service.web.domain}";
    in
    lib.mkIf config.service.web.forgejo {
      services = {
        forgejo = {
          enable = true;
          settings = {
            service.DISABLE_REGISTRATION = true;
            session.COOKIE_SECURE = true;
            server = {
              ROOT_URL = "https://${domain}/";
              DOMAIN = "${domain}";
              HTTP_PORT = 3001;
              LANDING_PAGE = "/explore/repos";
            };
          };
          stateDir = "/storage/volumes/forgejo";
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://localhost:3001";
        };
      };
    };
}
