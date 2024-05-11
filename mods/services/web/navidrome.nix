{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.web.navidrome = _lib.mkWebOpt "navi" 8093;
  config =
    let
      inherit (config._services.web.navidrome) enable port;
    in
    lib.mkIf enable {
      assertions = _lib.assertWeb;
      services.navidrome = {
        inherit enable;
        group = "media";
        settings = {
          MusicFolder = "/storage/media/Music";
          CacheFolder = "/var/cache/navidrome";
          EnableDownloads = true;
          EnableSharing = true;
          Port = port;
        };
      };
    };
}
