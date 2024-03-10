{
  config,
  lib,
  nuke,
  pkgs,
  ...
}:
{
  options.desktop.program = {
    prism = nuke.mkEnable;
    steam = nuke.mkEnable;
  };
  config =
    let
      inherit (lib) mkIf optionals;
      inherit (config.desktop.program) prism steam;
      inherit (pkgs)
        prismlauncher-qt5
        protontricks
        r2modman
        openjdk17
        openjdk8
        wqy_zenhei
        ;
      inherit (pkgs.pkgsi686Linux) gperftools;
    in
    {
      users.users.main.packages =
        optionals steam [
          protontricks
          r2modman
        ]
        ++ optionals prism [ prismlauncher-qt5 ];
      ### steam
      programs.steam = mkIf steam {
        enable = true;
        package = pkgs.steam.override {
          # required for source1 games.
          extraLibraries = pkgs: [
            wqy_zenhei
            gperftools
          ];
        };
      };
      hardware = mkIf steam {
        xone.enable = true;
        opengl.driSupport32Bit = true;
      };
      ### gives a reliable path for the jdks
      environment.etc = mkIf prism {
        "jdks/17".source = openjdk17 + /bin;
        "jdks/8".source = openjdk8 + /bin;
      };
    };
}
