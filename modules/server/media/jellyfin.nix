{
  config,
  lib,
  ...
}:
{
  options.crystal.server.media.jellyfin.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.media.jellyfin.enable {
    services = {
      # reverse proxy jellyfin
      nginx.virtualHosts."jelly.shimeji.cafe" = {
        useACMEHost = "shimeji.cafe";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8096";
          proxyWebsockets = true;
        };
      };
      jellyfin = {
        enable = true;
        group = "media";
      };
    };
    systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  };
}
