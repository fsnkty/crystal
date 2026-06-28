{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.users;
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkForce
    ;
in
{
  options.crystal.users = {
    root.disable = mkEnableOption "disable root user";
    main.setup = mkEnableOption "fsnkty, Madison, main user";
    amber.setup = mkEnableOption "Amber";
  };
  config = mkMerge [
    (mkIf cfg.root.disable {
      users = {
        mutableUsers = false; # disallow modifying users outside of the nixos config
        users.root = {
          hashedPassword = mkForce "!"; # invalid hash will never resolve
          shell = mkForce pkgs.shadow; # unuseable shell
        };
      };
    })
    (mkIf cfg.main.setup {
      users.users.main = {
        name = "fsnkty";
        description = "Madison";
        hashedPasswordFile = "/keys/user";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        uid = 1001; # 1000 sometimes gets taken up when installing with the default installer.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzo6UVJ72vS2sNW20QjMCmfCeChGPUT4YfY8VHiMVjv fsnkty@factory"
        ];
      };
    })
    (mkIf cfg.amber.setup {
      users.users.amber = {
        name = "amber";
        description = "Amber";
        hashedPasswordFile = "/keys/user_amber";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        uid = 1002; # +1 on fsnkty
      };
    })
  ];
}
