{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.fastboot.enable =
    lib.mkEnableOption "less strict systemd service orders, avoid on servers";
  config = lib.mkIf config.crystal.desktop.fastboot.enable {
    # Prevent systemd from waiting for network online
    systemd = {
      services.systemd-udev-settle.enable = false;
      network.wait-online.enable = false;
    };
    boot.initrd.systemd.network.wait-online.enable = false;
  };
}
