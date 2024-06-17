{
  config,
  _lib,
  lib,
  ...
}:
{
  options._programs.ssh = _lib.mkEnable;
  config.programs.ssh = lib.mkIf config._programs.ssh {
    knownHosts = {
      library = {
        extraHostNames = [ "192.168.0.3" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+1CxNCNvstjiRJFgJHVgqb/Mm1MJZOSoahwzgGXHMH";
      };
      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
