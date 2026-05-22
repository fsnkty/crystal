{
  config,
  lib,
  ...
}:
{
  options.crystal.server.media.jellyfin.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.media.jellyfin.enable {
    nixpkgs.overlays = [
      (final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (
          finalAttrs: previousAttrs: {
            # adds intro skip plugin script ( must be installed in the admin dashboard )
            # forces subtitle burn in when transcoding for all users all clients always
            installPhase = ''
              runHook preInstall
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html
              sed -i "s#f.AlwaysBurnInSubtitleWhenTranscoding=c.A.alwaysBurnInSubtitleWhenTranscoding()#f.AlwaysBurnInSubtitleWhenTranscoding=true#" dist/main.jellyfin.bundle.js
              sed -i "s#{key:"alwaysBurnInSubtitleWhenTranscoding",value:function(e){return void 0!==e?this.set("alwaysBurnInSubtitleWhenTranscoding",e.toString()):(0,o.G4)(this.get("alwaysBurnInSubtitleWhenTranscoding"),!1)}}#{key:"alwaysBurnInSubtitleWhenTranscoding",value:function(e){return true}}#" dist/main.jellyfin.bundle.js
              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web
              runHook postInstall
            '';
          }
        );
      })
    ];
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
    systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";

  };
}
