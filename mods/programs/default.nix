{
  config,
  lib,
  pkgs,
  ...
}: {
  options.program.prism = lib.mkEnableOption "";
  config = lib.mkIf config.program.prism {
    users.users.main.packages = [pkgs.prismlauncher-qt5];
    environment.etc = {
      "jdks/17".source = pkgs.openjdk17 + /bin;
      "jdks/8".source = pkgs.openjdk8 + /bin;
    };
  };
}
