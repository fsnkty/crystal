{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.system.hardware.gpu;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.crystal.system.hardware.gpu = {
    intel.enable = mkEnableOption "INTEL i915";
    amd.enable = mkEnableOption "AMD GPU rdna onwards";
    generic = mkEnableOption "generic GPU setup";
  };
  config = mkMerge [
    (mkIf cfg.intel.enable {
      crystal.system.hardware.gpu.generic = true;
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "i915";
      };
      boot = {
        kernelParams = [ "i915.enable_guc=2" ];
        initrd.kernelModules = [ "i915" ];
      };
      hardware.graphics = {
        extraPackages = [
          pkgs.intel-vaapi-driver
          pkgs.intel-media-driver
        ];
        extraPackages32 = [
          pkgs.pkgsi686Linux.intel-vaapi-driver
        ];
      };
    })
    (mkIf cfg.amd.enable {
      crystal.system.hardware.gpu.generic = true;
      boot.initrd.kernelModules = [ "amdgpu" ];
    })
    (mkIf cfg.generic {
      hardware = {
        firmware = [ pkgs.linux-firmware ];
        enableRedistributableFirmware = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };
    })
  ];
}
