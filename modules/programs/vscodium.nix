{
  config,
  pkgs,
  lib,
  ...
}: {
  options.crystal.programs.vscodium = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.programs.vscodium {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = [
        pkgs.vscode-extensions.jnoortheen.nix-ide
        pkgs.vscode-extensions.vscodevim.vim
        pkgs.vscode-extensions.tomoki1207.pdf
        pkgs.vscode-extensions.mkhl.direnv
      ];
    };
  };
}