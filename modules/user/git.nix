{ lib, config, ... }:
let
  cfg = config.crystal.users.main.git;
in
{
  options.crystal.users.main.git = {
    setup = lib.mkEnableOption "";
    signingkey = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/${config.networking.hostName}.pub";
    };
  };
  config = lib.mkIf cfg.setup {
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        user = {
          name = "fsnkty";
          email = "fsnkty@pm.me";
          signingkey = cfg.signingkey;
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
      };
    };
  };
}
