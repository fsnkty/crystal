{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.users;
  inherit (lib)
    mkEnableOption
    mkMerge
    mkIf
    mkForce
    ;
in
{
  options.users = {
    mainSetup = mkEnableOption "";
    disableRoot = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.mainSetup {
      users.users.main = {
        name = "fsnkty";
        hashedPasswordFile = "/keys/user";
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        uid = 1000;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzo6UVJ72vS2sNW20QjMCmfCeChGPUT4YfY8VHiMVjv fsnkty@factory"
        ];
      };
    })
    (mkIf cfg.disableRoot {
      users = {
        mutableUsers = false; # disallow modifying users outside of the nixos config
        users.root = {
          hashedPassword = mkForce "!"; # invalid hash will never resolve
          shell = mkForce pkgs.shadow; # unuseable shell
        };
      };
    })
  ];
}
