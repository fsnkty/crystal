{
  config,
  lib,
  ...
}:
{
  options.crystal.system.cleanup = lib.mkEnableOption "opinionated removal of some default packages, services, etc..";
  config = lib.mkIf config.crystal.system.cleanup {
    environment.defaultPackages = [ ];
    programs = {
      nano.enable = false;
      command-not-found.enable = false;
      bash.completion.enable = false;
    };
    xdg.sounds.enable = false;
    documentation = {
      enable = false;
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
    };
    boot.enableContainers = false;
  };
}
