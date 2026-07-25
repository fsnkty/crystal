{
  config,
  lib,
  ...
}:
{
  options.crystal.programs.neovim = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.programs.neovim {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      configure.customLuaRC = ''
        vim.o.number = true
        vim.o.relativenumber = false
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
        vim.o.expandtab = true
        vim.o.wrap = true
        vim.o.swapfile = false
      '';
    };
  };
}
