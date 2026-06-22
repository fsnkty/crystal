{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.darkmode.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.darkmode.enable {
    # gtk
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      }
    ];
  };
}
