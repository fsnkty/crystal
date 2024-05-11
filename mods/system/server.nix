{
  pkgs,
  lib,
  _lib,
  config,
  ...
}:
let
  cfg = config._system.server;
  inherit (lib) mkIf mkMerge;
  inherit (_lib) mkEnable;
in
{
  options._system.server = {
    headless = mkEnable;
  };
  config = mkMerge [
    (mkIf cfg.headless {
      systemd = {
        services = {
          "getty@tty1".enable = false;
          "autovt@".enable = false;
          "serial-getty@ttyS0".enable = lib.mkDefault false;
          "serial-getty@hvc0".enable = false;
        };
        enableEmergencyMode = false;
      };
      boot = {
        kernelParams = [
          "panic=1"
          "boot.panic_on_fail"
        ];
        loader.timeout = 0;
      };
    })
  ];
}
