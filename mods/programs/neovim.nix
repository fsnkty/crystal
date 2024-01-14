{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  mynv = let
    con = pkgs.neovimUtils.makeNeovimConfig {
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        null-ls-nvim
        nvim-treesitter
        nvim-tree-lua
        nvim-web-devicons
        lualine-nvim
        inputs.mountain.packages.${pkgs.system}.nvim
      ];
      withPython3 = false;
      withRuby = false;
      viAlias = true;
      vimAlias = true;
      customRC = ''
        lua << EOF
        local k = vim.keymap.set
        k("n", "<C-DOWN>", "<cmd>resize +2<cr>")
        k("n", "<C-UP>", "<cmd>resize -2<cr>")
        k("n", "<C-RIGHT>", "<cmd>vertical resize -2<cr>")
        k("n", "<C-LEFT>", "<cmd>vertical resize +2<cr>")
        k("n", "<S-LEFT>", "<C-w>h")
        k("n", "<S-DOWN>", "<C-w>j")
        k("n", "<S-UP>", "<C-w>k")
        k("n", "<S-RIGHT>", "<C-w>l")
        k('t', '<esc>', "<C-\\><C-n>")
        local o = vim.opt
        o.lazyredraw = true
        o.shell = "zsh"
        o.shadafile = "NONE"
        o.ttyfast = true
        o.termguicolors = true
        o.undofile = true
        o.smartindent = true
        o.tabstop = 2
        o.shiftwidth = 2
        o.shiftround = true
        o.expandtab = true
        o.cursorline = true
        o.relativenumber = true
        o.number = true
        o.viminfo = ""
        o.viminfofile = "NONE"
        o.wrap = false
        o.splitright = true
        o.splitbelow = true
        o.laststatus = 0
        o.cmdheight = 0
        vim.cmd.colorscheme 'mountain'
        vim.api.nvim_command("autocmd TermOpen * startinsert")
        vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")
        require('nvim-tree').setup {
          disable_netrw = true,
          hijack_netrw = true,
          hijack_cursor = true,
          sort_by = "case_sensitive",
          renderer = {
            group_empty = true,
          },
          filters = {
            dotfiles = true,
          },
        }
        require('lualine').setup {
          options = {
            icons_enabled = true,
            component_separators = { left = '>', right = '<'},
            section_separators = { left = '|', right = '|'},
            globalstatus = true,
          },
        }
        require('lspconfig').nil_ls.setup {
          autostart = true,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          cmd = {'nil'},
          settings = {
            ['nil'] = {
              formatting = {
                command = {'alejandra', '--quiet'},
              }
            }
          }
        }
        require('null-ls').setup {
          sources = {
            require('null-ls').builtins.formatting.alejandra,
            require('null-ls').builtins.diagnostics.deadnix
          }
        }
        EOF
      '';
    };
    wrapperArgs = let
      path = lib.makeBinPath [
        pkgs.deadnix
        pkgs.statix
        pkgs.nil
        pkgs.alejandra
      ];
    in
      con.wrapperArgs
      ++ [
        "--prefix"
        "PATH"
        ":"
        path
      ];
  in
    pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (con // {inherit wrapperArgs;});
in {
  options.program.neovim = lib.mkEnableOption "";
  config = lib.mkIf config.program.neovim {
    users.users.main.packages = [
      mynv
      pkgs.alejandra
    ];
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
