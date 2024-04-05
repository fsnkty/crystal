{ inputs, config, pkgs, lib, ... }:
let
  cfg = config.server.media;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  imports = [ "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix" ];

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
      boot.kernelParams = [ "i915.enable_guc=2" ];
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-media-driver pkgs.intel-compute-runtime ];
      };
      services.jellyfin = {
        enable = true;
        group = "media";
      };
    })
    (mkIf cfg.qbit {
      services.qbittorrent = {
        enable = true;
        package = inputs.qbit.legacyPackages.${pkgs.system}.qbittorrent-nox;
        group = "media";
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
            RootFolder = "${pkgs.vuetorrent}";
            AuthSubnetWhitelist = "0.0.0.0/0";
            AuthSubnetWhitelistEnabled = true;
          };
        };
      };
    })
  ];
}
