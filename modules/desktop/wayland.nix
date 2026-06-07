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
    };
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = "hyprland";
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
