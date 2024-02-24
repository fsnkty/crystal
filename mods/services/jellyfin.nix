{ config, pkgs, lib, ... }: {
  options.service.web.jelly = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.jelly {
    services.jellyfin = {
      enable = true;
      group = "media";
    };
    systemd.services.jellyfin.serviceConfig = {
      ProtectClock = true;
      DeviceAllow = [ "/dev/dri/renderD128" ];
      ProtectSystem = "strict";
      ReadWritePaths =
        [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/storage/media" ];
      ProtectHome = "yes";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      CapabilityBoundingSet = "";
    };
    boot.kernelParams = [ "i915.enable_guc=2" ];
    hardware.opengl = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver pkgs.intel-compute-runtime ];
    };
  };
}
