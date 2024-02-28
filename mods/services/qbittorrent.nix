{ config, pkgs, lib, nuke, inputs, ... }: {
  imports = [ "${inputs.qbit}/nixos/modules/services/torrent/qbittorrent.nix" ];
  #### awaiting pr ####
  options.service.web.qbittorrent = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8098;
  };
  config.services.qbittorrent = lib.mkIf config.service.web.qbittorrent.enable {
    enable = true;
    webuiPort = config.service.web.qbittorrent.port;
    torrentingPort = 43862;
    openFirewall = true;
    group = "media";
    package = pkgs.qbittorrent-nox.overrideAttrs {
      meta.mainProgram = "qbittorrent-nox";
    };
    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent.Session = {
        TempPathEnabled = true;
        TempPath = "/storage/media/torrents/incomplete/";
        DefaultSavePath = "/storage/media/torrents/";
        TorrentExportDirectory = "/storage/media/torrents/sources/";
        QueueingSystemEnabled = true;
        GlobalMaxInactiveSeedingMinutes = 43800;
        GlobalMaxSeedingMinutes = 10080;
        GlobalMaxRatio = 2;
        MaxActiveCheckingTorrents = 2;
        MaxActiveDownloads = 5;
        MaxActiveUploads = 15;
        MaxActiveTorrents = 20;
        IgnoreSlowTorrentsForQueueing = true;
        SlowTorrentsDownloadRate = 30; # kbps
        SlowTorrentsUploadRate = 30; # kbps
        MaxConnections = 600;
        MaxUploads = 200;
      };
      Preferences = {
        WebUI = {
          AlternativeUIEnabled = true;
          RootFolder = pkgs.fetchFromGitHub {
            owner = "VueTorrent";
            repo = "VueTorrent";
            rev = "v2.7.1";
            hash = "sha256-ZkeDhXDBjakTmJYN9LZtSRMSkaySt1MhS9QDEujBdYI=";
          };
          Username = "nuko";
          Password_PBKDF2 = ''
            "@ByteArray(g+9najSg/RPqxpxPVWLi9g==:TtILo6iFdNBeD0BhYuPtTYSPiP4QLc2M5dJ3Zxen28g9uy+g2Paq5KF1sU5POQF2ItChu1bujpp0ydLy9z7jSQ==)"'';
          ReverseProxySupportEnabled = true;
          TrustedReverseProxiesList = "qbit.${config.networking.domain}";
        };
        General.Locale = "en";
      };
    };
  };
}
