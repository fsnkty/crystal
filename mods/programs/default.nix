{ config, lib, nuke, pkgs, ... }:
let inherit (lib) mkIf optionals;
in {
  options.program = {
    prism = nuke.mkEnable;
    git = nuke.mkEnable;
    steam = nuke.mkEnable;
  };
  config = let inherit (config.program) prism git steam;
  in {
    users.users.main.packages = optionals prism [ pkgs.prismlauncher-qt5 ]
      ++ optionals steam [ pkgs.protontricks pkgs.r2modman ];
    ### prism
    environment.etc = mkIf prism {
      "jdks/17".source = pkgs.openjdk17 + /bin;
      "jdks/8".source = pkgs.openjdk8 + /bin;
    };
    ### git
    programs.git = mkIf git {
      enable = true;
      config = {
        init.defaultBranch = "main";
        user = {
          name = "nuko";
          email = "nuko@shimeji.cafe";
          signingkey =
            "/home/${config.users.users.main.name}/.ssh/id_ed25519.pub";
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
      };
    };
    ### steam
    programs.steam = mkIf steam {
      enable = true;
      package = pkgs.steam.override {
        # required for source1 games.
        extraLibraries = pkgs: [
          pkgs.wqy_zenhei
          pkgs.pkgsi686Linux.gperftools
        ];
      };
    };
    hardware = mkIf steam {
      xone.enable = true;
      opengl.driSupport32Bit = true;
    };
  };
}
