{ config, lib, ... }:
let
  cfg = config.crystal.system.hardware.cpu;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.crystal.system.hardware.cpu = {
    intel.enable = mkEnableOption "INTEL CPU";
    amd.enable = mkEnableOption "AMD CPU";
  };
  config = mkMerge [
    (mkIf cfg.intel.enable {
      hardware.cpu.intel.updateMicrocode = true;
      boot.initrd.kernelModules = [
        "kvm-intel" # virt acel
      ];
    })
    (mkIf cfg.amd.enable {
      hardware.cpu.amd.updateMicrocode = true;
      powerManagement.cpuFreqGovernor = "schedutil";
      boot = {
        kernelParams = [ "amd_pstate=guided" ];
        kernelModules = [
          "kvm-amd" # virt acel
          "amd_pstate" # best govenor for ryzen 2 onwards AFAICT - fsnkty
        ];
      };
    })
  ];
}
