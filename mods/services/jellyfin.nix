{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
{
  #### awaiting PR
  disabledModules = [ "${modulesPath}/services/misc/jellyfin.nix" ];
  imports = [ "${inputs.npmaster}/nixos/modules/services/misc/jellyfin.nix" ];
  ####
  options.service.web.jellyfin = lib.mkEnableOption "";
  config =
    let
      domain = "jelly.${config.service.web.domain}";
    in
    lib.mkIf config.service.web.jellyfin {
      services = {
        jellyfin = {
          enable = true;
          openFirewall = true;
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://localhost:8096";
        };
      };
      users.users.jellyfin.extraGroups = [ "media" ];
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
