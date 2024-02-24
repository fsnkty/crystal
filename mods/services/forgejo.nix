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
            ROOT_URL = "https://tea.${config.networking.domain}/";
            DOMAIN = "tea.${config.networking.domain}";
            HTTP_PORT = 8095;
            LANDING_PAGE = "/explore/repos";
          };
          other.SHOW_FOOTER_VERSION = false;
          DEFAULT.APP_NAME = "gitea";
          "ui.meta".AUTHOR = "gitea";
        };
      };
    };
  };
}
