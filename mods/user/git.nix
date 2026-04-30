## TODO:
## 1. move to hjem such that this setup only applys to the main user.
{ lib, config, ... }:
let
  cfg = config.users.git;
  inherit (lib) mkEnableOption mkMerge mkIf;
in
{
  options.users.git = {
    setup = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.setup {
      programs.git = {
        enable = true;
        config = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          user = {
            name = "fsnkty";
            email = "fsnkty@pm.me";
            signingkey = "~/.ssh/factory.pub";
          };
          gpg.format = "ssh";
          commit.gpgsign = true;
        };
      };
    })
  ];
}
