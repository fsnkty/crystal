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
    intel.enable = mkEnableOption "INTEL 2014+";
    amd.enable = mkEnableOption "AMD GPU rdna onwards";
    generic = mkEnableOption "generic GPU setup";
  };
  config = mkMerge [
    (mkIf cfg.intel.enable {
      crystal.system.hardware.gpu.generic = true;
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
      hardware.graphics.extraPackages = [
        pkgs.intel-ocl
        pkgs.intel-media-driver
        pkgs.intel-compute-runtime-legacy1
      ];
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
