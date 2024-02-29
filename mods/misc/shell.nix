{
  lib,
  nuke,
  config,
  pkgs,
  ...
}:
{
  options.misc.shell = {
    enable = nuke.mkEnable;
    prompt = lib.mkOption {
      type = lib.types.lines;
      default = "'%~ %# '";
    };
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
      histSize = 10000;
      histFile = "$HOME/.cache/zsh_history";
      shellInit = ''
        zsh-newuser-install() { :; }
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word
        (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[path]=none
        ZSH_HIGHLIGHT_STYLES[path_prefix]=none
        nr() {
          nix run nixpkgs#$1 -- ''${@:2}
        }
        ns() {
          nix shell nixpkgs#''${^@}
        }
      '';
      shellAliases = {
        ls = "eza";
        lg = "eza -lag";
        nf = "nix flake";
        no = "nh os";
        grep = "grep --color=auto";
        ssh-library = "ssh 192.168.0.3";
        pass = "wl-copy < /home/${config.users.users.main.name}/Documents/vault";
      };
      promptInit = "PROMPT=${config.misc.shell.prompt}";
    };
  };
}
