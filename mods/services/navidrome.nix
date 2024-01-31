{
  config,
  lib,
  ...
}: {
  options.service.web.navidrome = lib.mkEnableOption "";
  config = let
    domain = "navi.${config.service.web.domain}";
  in lib.mkIf config.service.web.navidrome {
    services = {
      navidrome = {
        enable = true;
        settings = {
          MusicFolder = "/storage/media/Music";
          DataFolder = "/storage/volumes/navidrome";
          CacheFolder = "/var/cache/navidrome";
          BaseUrl = domain;
          EnableDownloads = true;
          EnableSharing = true;
        };
      };
      nginx.virtualHosts."${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:4533";
      };
    };
    #users.users.navidrome.extraGroups = ["media"];
  };
}
