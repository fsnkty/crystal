{ config, pkgs, lib, ... }:
let
  cfg = config.desktop.gnome;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.desktop.gnome = {
    enable = mkEnableOption "enable base gnome desktop stuff";
    minimal = mkEnableOption "remove default applications";
    config = mkEnableOption "enable some config i like :3";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    })
    (mkIf cfg.minimal {
      services.gnome = {
        core-apps.enable = false;
        core-developer-tools.enable = false;
        games.enable = false;
      };
      environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
    })
    (mkIf cfg.config {
      programs.dconf.profiles.user.databases = [
        {
          lockAll = true; #prevent overrides
          settings = {
            "org/gnome/desktop/interface" = {
              accent-color = "purple";
              color-scheme = "prefer-dark";
            };
            "org/gnome/mutter" = {
              experimental-features = [
                "scale-monitor-framebuffer"
              ];
            };
          };
        }
      ];
    })
  ];
}
