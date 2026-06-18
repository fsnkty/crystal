{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.desktop.darkmode.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.darkmode.enable {
    # gtk "dark mode" pref
    # some non-gtk guis will also listen to this, e.g.. chromium & vscodium's "system" opt
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      }
    ];
  };
}
