{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.fastboot.enable = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.fastboot.enable {
    systemd = {
      services.systemd-udev-settle.enable = false;
      network.wait-online.enable = false;
    };
  };
}
