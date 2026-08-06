{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.crystal.programs.gaming;
in
{
  options.crystal.programs.gaming = {
    steam = lib.mkEnableOption "";
    thunderStore = lib.mkEnableOption "";
    prism = lib.mkEnableOption "";
    others = lib.mkEnableOption "";
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
      hjem.users.main.xdg.config.files."autostart/steam.desktop" = {
        text = ''
          [Desktop Entry]
          Name=Steam Auto Start
          Exec=steam %U -silent
          Icon=steam
          Type=Application
          X-GNOME-Autostart-enabled=true
        '';
        clobber = true;
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
    (lib.mkIf cfg.prism {
      environment.systemPackages = [
        pkgs.tetrio-desktop # tetr.io desktop client
      ];
    })
  ];
}
