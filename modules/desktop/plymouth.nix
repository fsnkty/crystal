{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.plymouth.setup = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.plymouth.setup {
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
  };
}
