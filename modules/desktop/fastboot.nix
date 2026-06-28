{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.fastboot.enable =
    lib.mkEnableOption "less strict systemd service orders, avoid on servers";
  config = lib.mkIf config.crystal.desktop.fastboot.enable {
    systemd = {
      services.systemd-udev-settle.enable = false;
      network.wait-online.enable = false;
    };
  };
}
