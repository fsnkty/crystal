{
  pkgs,
  lib,
  nuke,
  config,
  ...
}:
{
  options.user =
    let
      inherit (nuke) mkEnable;
      inherit (lib) mkOption;
      inherit (lib.types) str listOf package;
    in
    {
      noRoot = mkEnable;
      main = {
        enable = mkEnable;
        name = mkOption {
          type = str;
          default = "nuko";
        };
        packages = mkOption {
          type = listOf package;
          default = [ ];
        };
        keys = mkOption {
          type = listOf str;
          default = [ ];
        };
      };
    };
  config =
    let
      inherit (lib) mkIf mkForce;
      inherit (config.user) main noRoot;
    in
    {
      age.secrets.user = mkIf main.enable {
        file = ../../shhh/user.age;
        owner = main.name;
      };
      users = {
        mutableUsers = !main.enable;
        users = {
          ### disableRoot
          root = mkIf noRoot {
            hashedPassword = "!";
            shell = pkgs.shadow;
            home = mkForce "/home/root"; # for sudo.
          };
          ### configure main user
          main = mkIf main.enable {
            uid = 1000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPasswordFile = config.age.secrets.user.path;
            inherit (main) name;
            packages = builtins.attrValues { inherit (pkgs) wget yazi; } ++ main.packages;
            openssh.authorizedKeys.keys = main.keys;
          };
        };
      };
    };
}
