{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.crystal.desktop.fonts.setup = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.fonts.setup {
    # better for hidpi
    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
  };
}
