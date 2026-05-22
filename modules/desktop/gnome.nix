{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.crystal.desktop.gnome.setup = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.gnome.setup {
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
      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
      ];
      systemPackages = with pkgs.gnomeExtensions; [
        appindicator
        just-perfection
      ];
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
  };
}
