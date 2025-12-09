{ config, pkgs, lib, modulesPath, inputs, ... }:
let
  cfg = config.server.media;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  disabledModules = [
    "${modulesPath}/services/misc/jellyfin.nix"
  ];
  imports = [ "${inputs.jellyfinhardening}/nixos/modules/services/misc/jellyfin.nix" ];

  options.server.media = {
    jellyfin = mkEnableOption "";
    qbit = mkEnableOption "";
    group = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.group {
      users.groups.media = {
        gid = 1000;
        members = [ config.users.users.main.name ];
      };
    })
    (mkIf cfg.jellyfin {
      nixpkgs.overlays = with pkgs;[
        (
          final: prev:
          {
            jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
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
            });
          }
        )
      ];
      # hardware transcoding setup for uhd630 intel graphics
      boot.kernelParams = [ "i915.enable_guc=2" ];
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-vaapi-driver pkgs.intel-media-driver pkgs.intel-compute-runtime-legacy1 ];
      };
      systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";
      environment.sessionVariables = { LIBVA_DRIVER_NAME = "i965"; };
      services = {
        # reverse proxy jellyfin
        nginx.virtualHosts."jelly.shimeji.cafe" =
          {
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
            AlternativeUIEnabled = true;
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            AuthSubnetWhitelist = "0.0.0.0/0";
            AuthSubnetWhitelistEnabled = true;
          };
        };
      };
    })
  ];
}
