{ config, lib, modulesPath, inputs, ... }: {
  disabledModules = [ "${modulesPath}/services/audio/navidrome.nix" ];
  imports = [ "${inputs.navi}/nixos/modules/services/audio/navidrome.nix" ];
  #### awaiting PR ####
  options.service.web.navidrome = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.navidrome {
    services = {
      navidrome = {
        enable = true;
        group = "media";
        settings = {
          MusicFolder = "/storage/media/Music";
          CacheFolder = "/var/cache/navidrome";
          EnableDownloads = true;
          EnableSharing = true;
          Port = 8093;
        };
      };
    };
  };
}
