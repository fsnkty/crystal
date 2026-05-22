{
  config,
  lib,
  ...
}:
{
  options.crystal.desktop.audio.setup = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.desktop.audio.setup {
    services = {
      # audio
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };
    # allows pipewire to obtain RT prio as a user process
    security.rtkit.enable = true;
  };
}
