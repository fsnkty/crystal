{
  config,
  lib,
  ...
}: {
  options.service.web.komga = lib.mkEnableOption "";
  config = let
    domain = "komga.${config.service.web.domain}";
  in lib.mkIf config.service.web.komga {
    services = {
      komga = {
        enable = true;
        #stateDir = "/storage/volumes/komga";
        port = 8097;
        openFirewall = true;
      };
      nginx.virtualHosts."${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:8097";
      };
    };
    #users.users.komga.extraGroups = ["media"];
  };
}
