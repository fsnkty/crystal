{ config, lib, ... }:
{
  options.system.plymouth.setup = lib.mkEnableOption "enable plymouth and quiet booting";
  config = lib.mkIf config.system.plymouth.setup {
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
