{
  lib,
  config,
  ...
}: {
  options.desktop.audio = lib.mkEnableOption "";
  config = lib.mkIf config.desktop.audio {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    # realtime help, helps with nicer audio underload etc i think
    security.rtkit.enable = true;
  };
}
