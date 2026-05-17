{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.desktop;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.system.desktop = {
    darkmode = mkEnableOption "";
    fonts = mkEnableOption "";
    audio = mkEnableOption "";
    plymouth = mkEnableOption "";
    dont-wait-network = mkEnableOption "";
    gnome-minimal = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.gnome-minimal {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      services.gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
      environment = {
        gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
        systemPackages = with pkgs.gnomeExtensions; [ appindicator just-perfection ];
      };
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/mutter" = {
                experimental-features = [
                  "scale-monitor-framebuffer"
                  "xwayland-native-scaling"
                  "autoclose-xwayland"
                ];
              };
              "org/gnome/shell" = {
                enabled-extensions = with pkgs.gnomeExtensions; [
                  # system tray icons
                  appindicator.extensionUuid
                  # tweaks extension
                  just-perfection.extensionUuid
                ];
              };
            };
          }
        ];
      };
    })
    (mkIf cfg.dont-wait-network {
      systemd = {
        services.systemd-udev-settle.enable = false;
        network.wait-online.enable = false;
      };
    })
    (mkIf cfg.plymouth {
      boot = {
        plymouth.enable = true;
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];
        initrd.verbose = false;
        loader.timeout = 0;
      };
    })
    (mkIf cfg.darkmode {
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
    })
    (mkIf cfg.audio {
      services = {
        # audio
        pipewire = {
          enable = true;
          alsa.enable = true;
          pulse.enable = true;
        };
      };
      # allows pipewire to obtain RT prio as a user process
      security.rtkit.enable = true;
    })
    (mkIf cfg.fonts {
      # a far more readable font for HIDPI which portal has.
      console.font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
    })
  ];
}
