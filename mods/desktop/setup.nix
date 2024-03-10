{
  lib,
  nuke,
  config,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) str;
  inherit (nuke) mkEnable;
  cfg = config.desktop.setup;
in
{
  options.desktop.setup = {
    audio = mkEnable;
    greeter = {
      enable = mkEnable;
      command = mkOption { type = str; };
    };
  };
  config = {
    services = {
      # audio
      pipewire = mkIf cfg.audio {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      # greeter
      greetd = mkIf cfg.greeter.enable {
        enable = true;
        settings.default_session = {
          inherit (cfg.greeter) command;
          user = config.users.users.main.name;
        };
      };
    };
    # audio
    security.rtkit.enable = cfg.audio;
  };
}
