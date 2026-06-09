{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.crystal.desktop.gaming;
in
{
  options.crystal.desktop.gaming = {
    steam.enable = lib.mkEnableOption "";
    thunderStore.enable = lib.mkEnableOption "";
    prism.enable = lib.mkEnableOption "";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.steam.enable {
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
    (lib.mkIf cfg.thunderStore.enable {
      environment.systemPackages = [
        pkgs.r2modman
      ];
    })
    (lib.mkIf cfg.prism.enable {
      environment.systemPackages = [
        pkgs.prismlauncher
        pkgs.jre25_minimal
      ];
    })
  ];
}
