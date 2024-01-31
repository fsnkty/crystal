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
        stateDir = "/storage/volumes/komga";
        port = 5654;
      };
      nginx.virtualHost."${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "0.0.0.0:5654";
      };
    };
    users.users.komga.extraGroups = ["media"];
  };
}
