{ config, lib, nuke, ... }: {
  options.service.web.forgejo = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8095;
  };
  config.services.forgejo = lib.mkIf config.service.web.forgejo.enable {
    enable = true;
    settings = {
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
      server = {
        ROOT_URL = "https://tea.${config.networking.domain}/";
        DOMAIN = "tea.${config.networking.domain}";
        HTTP_PORT = config.service.web.forgejo.port;
        LANDING_PAGE = "/explore/repos";
      };
      other.SHOW_FOOTER_VERSION = false;
      DEFAULT.APP_NAME = "gitea";
      "ui.meta".AUTHOR = "gitea";
    };
  };
}
