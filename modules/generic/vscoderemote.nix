{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.crystal.system.vscode.remote = lib.mkEnableOption "vscode remote requirements";
  config = lib.mkIf config.crystal.system.vscode.remote {
    users.users.main.packages = [
      pkgs.wget
      pkgs.nixd
    ];
    programs.nix-ld.enable = true;
  };
}
