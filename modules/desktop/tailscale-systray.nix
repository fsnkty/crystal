{ config, lib, pkgs, ... }:
let
  cfg = config.crystal.desktop.tailscale-systray;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.crystal.desktop.tailscale-systray.enable = mkEnableOption "";
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.tailscale-systray
    ];
    systemd.user.services.tailscale-systray = {
      enable = true;
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      description = "Official Tailscale systray application for Linux";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.tailscale-systray} systray";
      };
    };
  };
}