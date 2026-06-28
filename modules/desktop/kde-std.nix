{
  config,
  lib,
  ...
}: {
  options.crystal.desktop.kde-std.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.kde-std.enable {
    services = {
      desktopManager.plasma6 = {
        enable = true;
      };
      displayManager.plasma-login-manager = {
        enable = true;
      };
    };
  };
}