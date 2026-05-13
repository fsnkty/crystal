{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.server.media;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.server.media = {
    jellyfin = mkEnableOption "";
    qbit = mkEnableOption "";
    group = mkEnableOption "";
    arrs = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.group {
      users.groups.media = {
        gid = 1000;
        members = [ config.users.users.main.name ];
      };
    })
    (mkIf cfg.jellyfin {
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
      # hardware transcoding setup for uhd630 intel graphics
      boot.kernelParams = [ "i915.enable_guc=2" ];
      hardware.graphics = {
        enable = true;
        extraPackages = [
          pkgs.intel-vaapi-driver
          pkgs.intel-media-driver
        ];
      };
      systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";
      environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";
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
    })
    (mkIf cfg.qbit {
      services.qbittorrent = {
        enable = true;
        group = "media";
        openFirewall = true;
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent.Session = rec {
            TempPathEnabled = true;
            DefaultSavePath = "/storage/media/torrents/";
            TempPath = DefaultSavePath + "incomplete/";
            TorrentExportDirectory = DefaultSavePath + "sources/";
            QueueingSystemEnabled = true;
            IgnoreSlowTorrentsForQueueing = true;
            SlowTorrentsDownloadRate = 40; # kbps
            SlowTorrentsUploadRate = 40; # kbps
            GlobalMaxInactiveSeedingMinutes = 43800;
            GlobalMaxSeedingMinutes = 10080;
            GlobalMaxRatio = 2;
            MaxActiveCheckingTorrents = 2;
            MaxActiveDownloads = 5;
            MaxActiveUploads = 15;
            MaxActiveTorrents = 20;
            MaxConnections = 600;
            MaxUploads = 200;
          };
          Preferences.WebUI = {
            AuthSubnetWhitelist = "0.0.0.0/0";
            AuthSubnetWhitelistEnabled = true;
          };
        };
      };
    })
    (mkIf cfg.arrs {
      services = {
        nginx.virtualHosts."see.shimeji.cafe" = {
          useACMEHost = "shimeji.cafe";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:5055";
            proxyWebsockets = true;
          };
        };
        seerr.enable = true;
        prowlarr.enable = true;
        radarr = {
          enable = true;
          group = "media";
        };
        sonarr = {
          enable = true;
          group = "media";
        };
        flaresolverr = {
          enable = true;
        };
        recyclarr = {
          enable = true;
          group = "media";
          configuration = 
          let
            mkProfiles = ids: map (id: {
              trash_id = id;
              reset_unmatched_scores.enabled = true;
            }) ids;
          in  
          {
            radarr.radarr-main = {
              api_key._secret = "/keys/radarr";
              base_url = "http://localhost:7878";
              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;
              quality_definition.type = "movie";
              quality_profiles = mkProfiles [
                "92e9a65a52ae48478fb8e9f34238d823" # base
                "722b624f9af1e492284c4bc842153a38" # anime
              ];
            };
            sonarr.sonarr-main = {
              api_key._secret = "/keys/sonarr";
              base_url = "http://localhost:8989";
              delete_old_custom_formats = true;
              replace_existing_custom_formats = true;
              quality_definition.type = "series";
              quality_profiles = mkProfiles [
                "e58cf4e090184db3b3d7c79c1a9e9b4a" # base
                "9d142234e45d6143785ac55f5a9e8dc9" # WEB-1080p
                "20e0fc959f1f1704bed501f23bdae76f" # Anime
              ];
            };
          };
        };
      };
    })
  ];
}
