{
  config,
  lib,
  pkgs,
  ...
}: {
  options.program.neovim = lib.mkEnableOption "";
  config = lib.mkIf config.program.neovim {
    users.users.main.packages = [
      (pkgs.callPackage ../../pkgs/neovim.nix)
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
