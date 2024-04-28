{
  pkgs,
  lib,
  _lib,
  config,
  ...
}:
let
  cfg = config._desktop;
  inherit (lib) mkIf mkMerge;
  inherit (_lib) mkEnable;
in
{
  options._desktop = {
    enable = mkEnable;
    rgb = mkEnable;
    gtk = mkEnable;
    audio = mkEnable;
    fonts = mkEnable;
    plymouth = mkEnable;
    console = mkEnable;
  };
  config = mkMerge [
    (mkIf cfg.enable {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "Hyprland";
          user = config.users.users.main.name;
        };
      };
      _programs = {
        hyprland = true;
        alacritty = true;
        fuzzel = true;
      };
      _desktop = {
        rgb = true;
        gtk = true;
        audio = true;
        fonts = true;
        plymouth = true;
      };
    })
    (mkIf cfg.fonts {
      fonts = {
        packages = [
          pkgs.noto-fonts
          (pkgs.callPackage ../assets/packages/SF-fonts.nix { })
        ];
        fontconfig = {
          defaultFonts = {
            sansSerif = [ "SF Pro Text" ];
            serif = [ "SF Pro Text" ];
            monospace = [ "Liga SFMono Nerd Font" ];
          };
          subpixel.rgba = "rgb";
        };
      };
    })
    (mkIf cfg.gtk {
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
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
          gtk-application-prefer-dark-theme=1
          gtk-font-name=SF Pro Text 12
        '';
      };
      qt = {
        enable = true;
        style = "adwaita-dark";
      };
    })
    (mkIf cfg.audio {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      security.rtkit.enable = true;
    })
    (mkIf cfg.rgb {
      services.hardware.openrgb = {
        enable = true;
        motherboard = "amd";
      };
    })
    (mkIf cfg.plymouth {
      boot = {
        plymouth.enable = true;
        initrd.verbose = false;
        kernelParams = [ "quiet" ];
      };
    })
    (mkIf cfg.console {
      console = {
        font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      };
    })
  ];
}
