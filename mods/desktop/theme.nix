{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  options.desktop.theme = lib.mkEnableOption "";
  config = lib.mkIf config.desktop.theme {
    users.users.main.packages = [
      pkgs.phinger-cursors
      inputs.mountain.packages.${pkgs.system}.gtk
      pkgs.flat-remix-icon-theme
    ];
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            gtk-theme = "phocus-mountain";
            icon-theme = "Flat-Remix-Purple-Dark";
            cursor-theme = "phinger-cursors";
            font-name = "SF Pro Text 12";
            monospace-font-name = "Liga SFMono Nerd Font";
            document-font-name = "SF Pro Text 12";
          };
        }
      ];
    };
    environment.etc = {
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name=phinger-cursors
        gtk-font-name=SF Pro Text 12
        gtk-icon-theme-name=Flat-Remix-Purple-Dark
        gtk-theme-name=phocus-mountain
      '';
      # qt compat mode is gtk2 based.
      "xdg/gtk-2.0/gtkrc".text = ''
        gtk-theme-name = "phocus-mountain"
      '';
    };
    qt = {
      enable = true;
      style = "gtk2";
      platformTheme = "gtk2";
    };
  };
}
