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
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.steam.enable {
      # TODO: FIXES:
      # various font configs use a `description` field which steams fontconfig doesnt recognise
      # unable to determine architecture of provider / ld config: Error reading "(null)" ELF header: invalid 'Elf' handle
      # run/opengl-driver/share/drirc.d is unlikely to appear in /run/host
      # run/opengl-driver-32/share/drirc.d is unlikely to appear in /run/host
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
      environment.systemPackages = [pkgs.r2modman];
    })
  ];
}
