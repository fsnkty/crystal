{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.program.neovim = lib.mkEnableOption "";
  config = lib.mkIf config.program.neovim {
    users.users.main.packages = with pkgs; [
      (pkgs.callPackage ../../pkgs/neovim.nix {inherit inputs;})
      deadnix
      statix
      nil
      alejandra
    ];
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
}
