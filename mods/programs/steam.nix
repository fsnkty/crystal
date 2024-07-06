{
  config,
  _lib,
  lib,
  pkgs,
  ...
}:
{
  options._programs.steam = _lib.mkEnable;
  config = lib.mkIf config._programs.steam {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        # required for source1 titles
        extraLibraries = pkgs: [
          pkgs.wqy_zenhei
          pkgs.pkgsi686Linux.gperftools
        ];
      };
      protontricks.enable = true;
      extraPackages = [ pkgs.r2modman ];
    };
    hardware.xone.enable = true;
  };
}
