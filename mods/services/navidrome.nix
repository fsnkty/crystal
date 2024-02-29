{
  config,
  lib,
  nuke,
  modulesPath,
  inputs,
  ...
}:
{
  disabledModules = [ "${modulesPath}/services/audio/navidrome.nix" ];
  imports = [ "${inputs.navi}/nixos/modules/services/audio/navidrome.nix" ];
  #### awaiting PR ####
  options.service.web.navidrome = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8093;
  };
  config.services.navidrome = lib.mkIf config.service.web.navidrome.enable {
    enable = true;
    group = "media";
    settings = {
      MusicFolder = "/storage/media/Music";
      CacheFolder = "/var/cache/navidrome";
      EnableDownloads = true;
      EnableSharing = true;
      Port = config.service.web.navidrome.port;
    };
  };
}
