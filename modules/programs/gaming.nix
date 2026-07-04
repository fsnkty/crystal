{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.programs.gaming;
in
{
  options.crystal.programs.gaming = {
    steam = lib.mkEnableOption "";
    thunderStore = lib.mkEnableOption "";
    prism = lib.mkEnableOption "";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.steam {
      programs.steam = {
        enable = true;
        extraPackages = [
          # some script used when starting steam makes use of `pactl` in some way
          pkgs.pulseaudio
          # otherwise "/run/current-system/sw/bin/getent is unlikely to appear in /run/host"
          pkgs.getent
        ];
      };
    })
    (lib.mkIf cfg.thunderStore {
      environment.systemPackages = [
        pkgs.r2modman
      ];
    })
    (lib.mkIf cfg.prism {
      environment.systemPackages = [
        pkgs.prismlauncher
        pkgs.jre25_minimal
      ];
    })
  ];
}
