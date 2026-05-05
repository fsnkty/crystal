{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  options.deployer.setup = lib.mkEnableOption "";
  config = lib.mkIf config.deployer.setup {
    # vscode server requires wget and nix-ld setup.
    # nixd and nixpkgs-fmt are for checks & formatting
    # wire-small for deployment
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) wget nixpkgs-fmt nixd;
    } + [ inputs.wire.package.x86_64-linux.wire-small ];
    programs.nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
    };
  };
}
