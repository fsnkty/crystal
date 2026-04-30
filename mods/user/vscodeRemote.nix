{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.vscode.remote.setup = lib.mkEnableOption "";
  config = lib.mkIf config.vscode.remote.setup {
    # vscode server
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) wget nixpkgs-fmt nixd;
    };
    programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
    };
  };
}
