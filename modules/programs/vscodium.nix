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
    hjem.users.main.xdg.config.files."VSCodium/User/settings.json" = {
      generator = lib.generators.toJSON { };
      value = {
        "workbench.activityBar.location" = "top";
        "workbench.layoutControl.enabled" = false;
        "workbench.browser.showInTitleBar" = false;
        "workbench.statusBar.visible" = false;
        "workbench.tips.enabled" = false;
        "workbench.editor.pinnedTabSizing" = "compact";
        "workbench.tree.enableStickyScroll" = false;
        "window.commandCenter" = false;
        "window.density.editorTabHeight" = "compact";
        "breadcrumbs.enabled" = false;
        "editor.stickyScroll.enabled" = false;
        "editor.minimap.enabled" = false;
        "chat.agentsControl.enabled" = "hidden";
        "terminal.integrated.initialHint" = false;
        "terminal.integrated.stickyScroll.enabled" = false;
        "terminal.integrated.defaultLocation" = "editor";
        "git.enableSmartCommit" = true;
      };
      # overwrite existing unmanaged file, if present.
      # used in case vscode edits the file for whatever reason
      clobber = true;
    };
  };
}