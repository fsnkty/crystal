{
  config,
  lib,
  nuke,
  pkgs,
  ...
}:
{
  options.desktop.program =
    let
      inherit (nuke) mkEnable;
    in
    {
      prism = mkEnable;
      steam = mkEnable;
    };
  config =
    let
      inherit (lib) mkIf optionals;
      inherit (config.desktop.program) prism steam;
    in
    {
      users.users.main.packages =
        let
          inherit (pkgs) prismlauncher-qt5 protontricks r2modman;
        in
        optionals prism [ prismlauncher-qt5 ]
        ++ optionals steam [
          protontricks
          r2modman
        ];
      ### steam
      programs.steam = mkIf steam {
        enable = true;
        package = pkgs.steam.override {
          # required for source1 games.
          extraLibraries =
            let
              inherit (pkgs) wqy_zenhei;
              inherit (pkgs.pkgs.i686Linux) gperftools;
            in
            pkgs: [
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
      environment.etc =
        let
          inherit (pkgs) openjdk17 openjdk8;
        in
        mkIf prism {
          "jdks/17".source = openjdk17 + /bin;
          "jdks/8".source = openjdk8 + /bin;
        };
    };
}
