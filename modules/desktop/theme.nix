{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.desktop.theme.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.theme.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.kdePackages)
        # gtk
        kde-gtk-config
        breeze-gtk
        # kde
        breeze
        breeze-icons
        ocean-sound-theme
        qqc2-breeze-style
        qqc2-desktop-style
        ;
    };
    # gtk
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Breeze";
            };
            "org/gnome/desktop/wm/preferences".button-layout = "minimize,mazimize,close";
          };
        }
      ];
    };
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    # qt
    qt = {
      platformTheme = "kde";
      style = "breeze";
    };
    xdg.icons = {
      enable = true;
      fallbackCursorThemes = [ "breeze_cursors" ];
    };
  };
}
