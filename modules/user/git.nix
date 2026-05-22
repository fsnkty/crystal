{ lib, config, ... }:
{
  options.crystal.users.main.git.setup = lib.mkEnableOption "";
  config = lib.mkMerge [
    (lib.mkIf config.crystal.users.main.git.setup {
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
