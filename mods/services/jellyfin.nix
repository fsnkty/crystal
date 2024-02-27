{ config, pkgs, lib, nuke, ... }: {
  options.service.web.jellyfin = {
    enable = lib.mkEnableOption "";
    port = nuke.mkDefaultInt 8096;
  };
  # yet to find a way to make jellyfin take a webui port.. *sigh*
  config = lib.mkIf config.service.web.jellyfin.enable {
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
