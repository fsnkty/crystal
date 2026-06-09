{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.desktop.darkmode.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.darkmode.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        whitesur-icon-theme
        phinger-cursors;
    };
    # gtk "dark mode" pref
    # some non-gtk guis will also listen to this, e.g.. chromium & vscodium's "system" opt
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          icon-theme = "WhiteSur-dark";
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
