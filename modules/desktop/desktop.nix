{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.crystal.desktop;
  inherit (lib)
    mkMerge
    mkEnableOption
    mkIf
    ;
in
{
  options.crystal.desktop = {
    fastboot = mkEnableOption "";
    plymouth = mkEnableOption "";
    fonts = mkEnableOption "";
    theme = {
      gtk = mkEnableOption "";
      qt = mkEnableOption "";
    };
    xdg = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.fastboot
    {
      # Prevent systemd from waiting for network online
      systemd = {
        services.systemd-udev-settle.enable = false;
        network.wait-online.enable = false;
      };
      boot.initrd.systemd.network.wait-online.enable = false;
    })
    (mkIf cfg.plymouth
    {
      boot = {
        plymouth.enable = true;
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
          "vt.global_cursor_default=0"
        ];
        initrd.verbose = false;
      };
    })
    (mkIf cfg.fonts
    {
      # better for hidpi
      console.font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      fonts = {
        packages = lib.mkForce [
          pkgs.noto-fonts
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-cjk-serif
          pkgs.noto-fonts-color-emoji
        ];
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
    })
    (mkIf cfg.theme.gtk
    {
      environment.systemPackages = [
        pkgs.kdePackages.breeze-gtk
      ];
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
    })
    (mkIf cfg.theme.qt
    {
      environment.systemPackages = builtins.attrValues {
      inherit (pkgs.kdePackages)
        breeze
        breeze-icons
        ocean-sound-theme
        qqc2-breeze-style
        qqc2-desktop-style
        ;
      };
      qt = {
        platformTheme = "kde";
        style = "breeze";
      };
    })
    (mkIf cfg.xdg
    {
      xdg = {
        terminal-exec = {
          enable = true;
          settings.default = [ "alacritty.desktop" ];
        };
        icons.fallbackCursorThemes = [ "breeze_cursors" ];
        mime =
        let
          links = {
            # proton mail
            "text/calendar" = "proton-mail.desktop";
            "x-scheme-handler/mailto" = "proton-mail.desktop";
            "x-scheme-handler/proton-inbox" = "proton-mail.desktop";
            "x-scheme-handler/tel" = "proton-mail.desktop";
            # vscode-oss
            "text/plain" = "codium.desktop";
            # chrome
            "x-scheme-handler/geo" = "google-maps-geo-handler.desktop";
            "x-scheme-handler/http" = "google-chrome.desktop";
            # biwarden
            "x-scheme-handler/bitwarden" = "bitwarden.desktop";
          };
        in
        {
          defaultApplications = links;
          addedAssociations = links;
        };
      };
    })
  ];
}
