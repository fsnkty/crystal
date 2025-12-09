{ config, inputs, pkgs, lib, ... }:
let
  cfg = config.shell;
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) lines;
in
{
  options.shell = {
    setup = mkEnableOption "enable customzied zsh shell";
    prompt = mkOption {
      type = lines;
      default = "'%~ %# '";
    };
  };
  config =
    let
        inherit (pkgs) eza zsh dash;
        inherit (lib) getExe mkForce;
    in
    mkIf cfg.setup {
      users.users.main = {
        shell = mkForce zsh;
        packages = [ eza ];
      };
      environment = {
        shells = [ zsh ];
        binsh = getExe dash;
        variables = {
          XDG_DATA_HOME = ''"$HOME"/.local/share'';
          XDG_CONFIG_HOME = ''"$HOME"/.config'';
          XDG_STATE_HOME = ''"$HOME"/.local/state'';
          XDG_CACHE_HOME = ''"$HOME"/.cache'';
        };
      };
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
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
          grep = "grep --color=auto";
          rebuild-library = "nixos-rebuild switch --target-host fsnkty@119.224.63.166 --flake .#library --sudo --ask-sudo-password";
        };
        promptInit = "PROMPT=${cfg.prompt}";
      };
    };
}
