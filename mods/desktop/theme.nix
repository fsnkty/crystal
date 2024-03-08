{
  lib,
  nuke,
  pkgs,
  inputs,
  config,
  colours,
  ...
}:
{
  options.desktop.theme = {
    fonts = nuke.mkEnable;
    gtkqt = nuke.mkEnable;
    console = nuke.mkEnable;
  };
  config =
    let
      inherit (lib) mkIf;
      inherit (config.desktop.theme) fonts gtkqt console;
      inherit (colours) alpha accent primary;
    in
    {
      ### fonts
      fonts = mkIf fonts {
        packages = builtins.attrValues {
          #sfFonts = pkgs.callPackage ../../pkgs/sfFonts.nix { };
          inherit (pkgs) noto-fonts-emoji noto-fonts-extra noto-fonts-cjk;
        };
        fontconfig = {
          defaultFonts = {
            sansSerif = [ "SF Pro Text" ];
            serif = [ "SF Pro Text" ];
            monospace = [ "Liga SFMono Nerd Font" ];
          };
          subpixel.rgba = "rgb";
        };
      };
      ### gtkqt
      users.users.main.packages = mkIf gtkqt [
        pkgs.phinger-cursors
        inputs.mountain.packages.${pkgs.system}.gtk
        pkgs.flat-remix-icon-theme
      ];
      programs.dconf = mkIf gtkqt {
        enable = true;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
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
      environment.etc = mkIf gtkqt {
        "xdg/gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-cursor-theme-name=phinger-cursors
          gtk-font-name=SF Pro Text 12
          gtk-icon-theme-name=Flat-Remix-Purple-Dark
          gtk-theme-name=phocus-mountain
        '';
      };
      qt = mkIf gtkqt {
        enable = true;
        style = "gtk2";
        platformTheme = "gtk2";
      };
      ### console
      console = mkIf console {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
        colors = [
          "000000" # match boot.
          alpha.red
          alpha.green
          alpha.yellow
          alpha.blue
          alpha.magenta
          alpha.cyan
          alpha.white
          accent.red
          accent.green
          accent.yellow
          accent.blue
          accent.magenta
          accent.cyan
          accent.white
          primary.fg
        ];
      };
    };
}
