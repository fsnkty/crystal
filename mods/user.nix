{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._user =
    let
      inherit (_lib) mkEnable;
      inherit (lib) mkOption types;
      inherit (types) str listOf package;
    in
    {
      mediaGroup = mkEnable;
      disableRoot = mkEnable;
      immutable = mkEnable;
      main = {
        enable = mkEnable;
        packages = mkOption {
          type = listOf package;
          default = [ ];
        };
        loginKeys = mkOption {
          type = listOf str;
          default = [ ];
        };
        shell = mkEnable;
      };
    };
  config =
    let
      inherit (lib) mkIf mkDefault mkForce;
      inherit (config._user)
        main
        disableRoot
        mediaGroup
        immutable
        ;
      inherit (config.users.users.main) name;
    in
    lib.mkMerge [
      (mkIf main.enable {
        age.secrets.user = {
          file = ../assets/age/user.age;
          owner = name;
        };
        users.users.main = {
          name = "nuko";
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.age.secrets.user.path;
          openssh.authorizedKeys.keys = main.loginKeys;
          packages = builtins.attrValues { inherit (pkgs) wget yazi eza; } ++ main.packages;
        };
      })
      (mkIf immutable {
        users = {
          mutableUsers = false;
          users.main.uid = mkIf main.enable 1000;
          groups.media.gid = mkIf mediaGroup 1000;
        };
      })
      (mkIf disableRoot {
        users.users.root = {
          hashedPassword = mkDefault "!"; # cannot eval.
          home = mkDefault "/home/root"; # for sudo use.
          shell = mkForce pkgs.shadow;
        };
      })
      (mkIf mediaGroup {
        users.groups.media = {
          members = mkIf main.enable [ name ];
        };
      })
      (mkIf main.shell {
        users.users.main.shell = pkgs.zsh;
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
          shellAliases = {
            ls = "eza";
            lg = "eza -lag";
            nf = "nix flake";
            library = "ssh 192.168.0.3";
            pass = "wl-copy < /home/${name}/Documents/vault";
          };
          shellInit = ''
            nr() {
              nix run nixpkgs#$1 -- ''${@:2}
            }
            ns() {
              nix shell nixpkgs#''${^@}
            }
            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word
            bindkey '^H' backward-kill-word
            bindkey '5~' kill-word
            (( ''${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[path]=none
            ZSH_HIGHLIGHT_STYLES[path_prefix]=none
            zsh-newuser-install() { :; }
          '';
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;
          histFile = "$HOME/.cache/zsh_history";
          histSize = 10000;
        };
        programs.starship = {
          enable = true;
          settings = {
            add_newline = false;
            hostname.format = " in [$ssh_symbol$hostname]($style)";
            username = {
              style_user = "bold cyan";
              format = "[$user]($style)";
            };
            git_branch = {
              symbol = "  ";
              format = "[$symbol$branch(:$remote_branch)]($style)";
            };
            format = ''
              [$directory$git_branch$git_commit$git_state](bold red)
              [❤️ $username$hostname](bold red)$character
            '';
            character = {
              success_symbol = "➜";
              error_symbol = "➜";
            };
          };
        };
      })
    ];
}
