{lib, config, ...}:
{
  options.crystal.desktop.shell = {
    enable = lib.mkEnableOption "";
  };
  config = lib.mkIf config.crystal.desktop.shell.enable {
    programs = {
      dms-shell = {
        enable = true;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };
        enableAudioWavelength = false;
        enableCalendarEvents = false;
        enableDynamicTheming = false;
        enableVPN = false;
      };
      # the wayland compositor
      hyprland = {
        enable = true;
        # systemd based management 
        withUWSM = true;
      };
      hyprlock.enable = true;
    };
    services.greetd = {
      enable = true;
      settings = {
        inital_session = {
          command = "uwsm start default";
          user = "fsnkty";
        };
        default_session = {
          command = "uwsm start default";
          user = "fsnkty";
        };
      };
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
