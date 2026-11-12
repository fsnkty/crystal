{ config
, inputs
, lib
, ...
}:
{
  options.crystal.server.media.qbittorrent.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.server.media.qbittorrent.enable {
    services.qbittorrent = {
      enable = true;
      group = "media";
      openFirewall = true; 
      extraArgs = [ "--confirm-legal-notice" ];
      # 5.3.X ( in unstable ) isnt widely accepted, 5.2.X ( in stable ) is.
      package = inputs.nixpkgs.legacyPackages."x86_64-linux".qbittorrent-nox;
      /*
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = rec {
          TempPathEnabled = true;
          DefaultSavePath = "/storage/media/torrents/";
          TempPath = DefaultSavePath + "incomplete/";
          TorrentExportDirectory = DefaultSavePath + "sources/";
          IgnoreSlowTorrentsForQueueing = true;
          SlowTorrentsDownloadRate = 40; # kbps
          SlowTorrentsUploadRate = 40; # kbps
        };
        Preferences.WebUI = {
          AuthSubnetWhitelist = "0.0.0.0/0";
          AuthSubnetWhitelistEnabled = true;
        };
      };
      */
    };
  };
}
