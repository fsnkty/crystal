{ config, lib, ... }: {
  options.service.web.forgejo = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.forgejo {
    services = {
      forgejo = {
        enable = true;
        settings = {
          service.DISABLE_REGISTRATION = true;
          session.COOKIE_SECURE = true;
          server = {
            ROOT_URL = "https://tea.${config.service.web.domain}/";
            DOMAIN = "tea.${config.service.web.domain}";
            HTTP_PORT = 3001;
            LANDING_PAGE = "/explore/repos";
          };
          other.SHOW_FOOTER_VERSION = false;
          DEFAULT.APP_NAME = "gitea";
          "ui.meta".AUTHOR = "gitea";
        };
      };
      nginx.virtualHosts."tea.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:3001";
      };
    };
  };
}
