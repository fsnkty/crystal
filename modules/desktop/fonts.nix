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
    fonts = {
      packages = builtins.attrValues {
        inherit (pkgs)
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          ;
      };
      enableDefaultPackages = false;
      fontconfig = {
        defaultFonts = lib.mkForce {
          monospace = [ "Noto Sans Mono" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
