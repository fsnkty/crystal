{
  config,
  lib,
  pkgs,
  ...
}: {
  # prism launcher is an alternative minecraft client manager.
  options.program.prism = lib.mkEnableOption "";
  config = lib.mkIf config.program.prism {
    # using the qt5 version as it responds to gtk adapt qt themes better
    users.users.main.packages = [pkgs.prismlauncher-qt5];
    # give the jdkbin a consistent path
    environment.etc = {
      "jdks/17".source = pkgs.openjdk17 + /bin;
      "jdks/8".source = pkgs.openjdk8 + /bin;
    };
  };
}
