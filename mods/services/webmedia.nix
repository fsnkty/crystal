{
  config,
  pkgs,
  lib,
  nuke,
  inputs,
  modulesPath,
  ...
}:
let
  inherit (nuke) mkWebOpt;
  inherit (lib) mkIf;
in
{
  # awaiting prs
  # komga https://github.com/NixOS/nixpkgs/pull/292477
  # navidrome https://github.com/NixOS/nixpkgs/pull/288687
  disabledModules = [
    "${modulesPath}/services/web-apps/komga.nix"
    "${modulesPath}/services/audio/navidrome.nix"
  ];
  imports = [
    "${inputs.master}/nixos/modules/services/web-apps/komga.nix"
    "${inputs.navi}/nixos/modules/services/audio/navidrome.nix"
  ];

  options.service.web = {
    komga = mkWebOpt 8097;
    navidrome = mkWebOpt 8093;
    jellyfin = mkWebOpt 8096;
  };
  config =
    let
      inherit (config.service.web) komga navidrome jellyfin;
      enable = true;
      group = "media";
    in
    {
      services = {
        komga = mkIf komga.enable {
          inherit enable group;
          inherit (komga) port;
        };
        navidrome = mkIf navidrome.enable {
          package = inputs.navi.legacyPackages.${pkgs.system}.navidrome;
          inherit enable group;
          settings = {
            MusicFolder = "/storage/media/Music";
            CacheFolder = "/var/cache/navidrome";
            EnableDownloads = true;
            EnableSharing = true;
            Port = navidrome.port;
          };
        };
        jellyfin = mkIf jellyfin.enable {
          # yet to find a proper way to declare a webui port.
          inherit enable group;
        };
      };
      # hardening which isnt appropriate for upstream.
      systemd.services.jellyfin.serviceConfig = mkIf jellyfin.enable {
        DeviceAllow = [ "/dev/dri/renderD128" ];
        ProtectSystem = "strict";
        ProtectHome = "yes";
        ReadWritePaths = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
          "/storage/media"
        ];
        # these options seem reasonable for upstream but likely not worth a PR
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        CapabilityBoundingSet = "";
      };
      # video hardware accel setup
      boot.kernelParams = mkIf jellyfin.enable [ "i915.enable_guc=2" ];
      hardware.opengl = mkIf jellyfin.enable {
        enable = true;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.intel-compute-runtime
        ];
      };
    };
}
