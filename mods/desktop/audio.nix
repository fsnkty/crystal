{ lib, nuke, config, ... }: {
  options.desktop.audio = nuke.mkEnable;
  config = lib.mkIf config.desktop.audio {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
  };
}
