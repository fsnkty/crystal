{ config, lib, modulesPath, inputs, ... }:
{
  disabledModules = [ "${modulesPath}/services/audio/navidrome.nix" ];
  imports = [ "${inputs.navi}/nixos/modules/services/audio/navidrome.nix" ];
  options.service.web.navidrome = lib.mkEnableOption "";
  config =
    let
      domain = "navi.${config.service.web.domain}";
    in
    lib.mkIf config.service.web.navidrome {
      services = {
        navidrome = {
          enable = true;
          group = "media";
          settings = {
            MusicFolder = "/storage/media/Music";
            CacheFolder = "/var/cache/navidrome";
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
    };
}
