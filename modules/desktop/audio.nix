{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.audio.setup = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.audio.setup {
    services = {
      pipewire = {
        enable = true;
        # compat
        alsa.enable = true;
        pulse.enable = true;
      };
    };
    # allows pipewire to obtain RT prio as a user process
    security.rtkit.enable = true;
  };
}
