{
  lib,
  config,
  pkgs,
  ...
}: {
  options.misc.disableRoot = lib.mkEnableOption "";
  config = lib.mkIf config.misc.disableRoot {
    users.users.root = {
      hashedPassword = "!";
      shell = pkgs.shadow;
      home = lib.mkForce "/home/root";# for sudo.
    };
  };
}
