{
  lib,
  config,
  pkgs,
  ...
}: {
  options.misc.disableRoot = lib.mkEnableOption "";
  config = lib.mkIf config.misc.disableRoot {
    users.users.root = {
      hashedPassword = "!"; # wont eval
      shell = pkgs.shadow; # more informative than just no password
      home = lib.mkForce "/home/root"; # for sudo
    };
  };
}
