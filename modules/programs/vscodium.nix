{ config
, pkgs
, lib
, ...
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
        pkgs.vscode-extensions.jdinhlife.gruvbox
        pkgs.vscode-extensions.geequlim.godot-tools
        pkgs.vscode-extensions.ms-vscode.cmake-tools
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "cpptools";
            publisher = "ms-vscode";
            version = "1.35.4";
            sha256 = "sha256-1n4dVni2LoLJSMwVPakHjVaQHUaxNVOX8r9BEyAeumE=";
          }
          {
            name = "qt-core";
            publisher = "TheQtCompany";
            version = "1.17.1";
            sha256 = "sha256-ZqiMHI6SgMLIBcxxsoPXxhqditXXtwZgXwxXv1PKLI8=";
          }
          {
            name = "qt-cpp";
            publisher = "TheQtCompany";
            version = "1.17.1";
            sha256 = "sha256-n+2qMNGe4mVxLlnfdhK0imOr0lCUY5eT/PJhX0PJgj0=";
          }
        ];
    };
    home.file.".config/VSCodium/User/settings.json".text =
      lib.generators.toJSON { }
        {
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
          "workbench.colorTheme" = "Gruvbox Light Soft";
          "workbench.editorAssociations" = {
            "{git,gitlens,chat-editing-snapshot-text-model,copilot,git-graph,git-graph-3}:/**/*.qrc" = "default";
            "*.qrc" = "qt-core.qrcEditor";
          };
        }
    ;
  };
}
