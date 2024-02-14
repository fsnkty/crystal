{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
{
  disabledModules = [ "${modulesPath}/services/misc/jellyfin.nix" ];
  imports = [ "${inputs.master}/nixos/modules/services/misc/jellyfin.nix" ];
  #### awaiting PR ####
  options.service.web.jellyfin = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.jellyfin {
    services = {
      jellyfin = {
        enable = true;
        group = "media";
        openFirewall = true;
      };
      nginx.virtualHosts."jelly.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:8096";
      };
    };
    boot.kernelParams = [ "i915.enable_guc=2" ];
    hardware.opengl = {
      enable = true;
      extraPackages = [
        pkgs.intel-media-driver
        pkgs.intel-compute-runtime
      ];
    };
  };
}
