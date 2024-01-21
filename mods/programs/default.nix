{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
in {
  options.program = {
    prism = mkEnableOption "";
    git = mkEnableOption "";
    steam = mkEnableOption "";
  };
  config = let
    inherit (config.program) prism git steam;
  in {
    ### prism
    users.users.main.packages = mkIf prism [pkgs.prismlauncher-qt5];
    environment.etc = mkIf prism {
      "jdks/17".source = pkgs.openjdk17 + /bin;
      "jdks/8".source = pkgs.openjdk8 + /bin;
    };
    ### git
    programs.git = mkIf git {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
        user = {
          name = "nuko";
          email = "host@nuko.city";
        };
      };
    };
    ### steam
    programs.steam = mkIf steam {
      enable = true;
      package = pkgs.steam.override {
        # required for source1 games.
        extraLibraries = pkgs: [pkgs.wqy_zenhei pkgs.pkgsi686Linux.gperftools];
      };
    };
  };
}
