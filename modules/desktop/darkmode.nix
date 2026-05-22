{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.darkmode.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.darkmode.enable {
    # gtk "dark mode" pref, ( some non-gtk guis will also listen to this )
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      }
    ];
    # similarly to gtk, just as a way to set a "dark mode", aditionally should also hopefully "fit in" more with gtk apps.
    qt = {
      enable = true;
      style = "adwaita-dark";
    };
  };
}
