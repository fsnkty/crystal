{
  config,
  lib,
  nuke,
  inputs,
  modulesPath,
  ...
}:
{
  disabledModules = [ "${modulesPath}/services/web-apps/komga.nix" ];
  imports = [ "${inputs.komga}/nixos/modules/services/web-apps/komga.nix" ];
  options.service.web.komga = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8097;
  };
  config.services.komga = lib.mkIf config.service.web.komga.enable {
    enable = true;
    port = config.service.web.komga.port;
    openFirewall = true;
  };
}
