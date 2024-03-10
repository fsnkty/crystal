{
  config,
  lib,
  nuke,
  ...
}:
{
  options.program = {
    git = nuke.mkEnable;
    ssh = nuke.mkEnable;
  };
  config =
    let
      inherit (lib) mkIf;
      inherit (config.program) git ssh;
    in
    {
      programs = {
        ### git
        git = mkIf git {
          enable = true;
          config = {
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            user = {
              name = "nuko";
              email = "nuko@shimeji.cafe";
              signingkey = "/home/${config.users.users.main.name}/.ssh/id_ed25519.pub";
            };
            gpg.format = "ssh";
            commit.gpgsign = true;
          };
        };
        ### ssh
        ssh = mkIf ssh {
          knownHosts = {
            library = {
              extraHostNames = [
                "tea.shimeji.cafe"
                "192.168.0.3"
                "119.224.63.166"
              ];
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+1CxNCNvstjiRJFgJHVgqb/Mm1MJZOSoahwzgGXHMH";
            };
            factory = {
              extraHostNames = [ "192.168.0.4" ];
              publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLJR5DDyMYyKoUaZDML29f1AEJZ98nfizrdJ8jCLP6h";
            };
            "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };
        };
      };
    };
}
