{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.misc.shell = {
    enable = lib.mkEnableOption "";
    prompt = lib.mkOption { type = lib.types.lines; };
  };
  config = lib.mkIf config.misc.shell.enable {
    users.users.main.shell = lib.mkForce pkgs.zsh;
    environment = {
      shells = [ pkgs.zsh ];
      binsh = lib.getExe pkgs.dash;
      variables = {
        XDG_DATA_HOME = ''"$HOME"/.local/share'';
        XDG_CONFIG_HOME = ''"$HOME"/.config'';
        XDG_STATE_HOME = ''"$HOME"/.local/state'';
        XDG_CACHE_HOME = ''"$HOME"/.cache'';
      };
    };
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableGlobalCompInit = false;
      histSize = 10000;
      histFile = "$HOME/.cache/zsh_history";
      shellInit = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word
        (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[path]=none
        ZSH_HIGHLIGHT_STYLES[path_prefix]=none
        zsh-newuser-install() { :; }
        nr() {
          nix run nixpkgs#$1 -- ''${@:2}
        }
        ns() {
          nix shell nixpkgs#''${^@}
        }
      '';
      shellAliases = {
        ls = "eza";
        grep = "grep --color=auto";
        ssh-library = "ssh 192.168.0.3";
      };
      promptInit = "PROMPT=${config.misc.shell.prompt}";
    };
  };
}
