{ lib, config, ... }:
{
  options.crystal.desktop.shell = {
    enable = lib.mkEnableOption "";
  };
  config = lib.mkIf config.crystal.desktop.shell.enable {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
    services.greetd = {
      enable = true;
      settings = {
        inital_session = {
          command = "uwsm start default";
          user = "fsnkty";
        };
      };
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
