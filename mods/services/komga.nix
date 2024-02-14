{ config, lib, ... }:
{
  options.service.web.komga = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.komga {
    services = {
      komga = {
        enable = true;
        port = 8097;
        openFirewall = true;
      };
      nginx.virtualHosts."komga.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:8097";
      };
    };
  };
}
