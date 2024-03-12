{
  lib,
  nuke,
  config,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (nuke) mkEnable;
  cfg = config.desktop.setup;
in
{
  options.desktop.setup = {
    audio = mkEnable;
    rgb = mkEnable;
    ply = mkEnable;
    greeter = {
      enable = mkEnable;
      command = mkOption { type = lib.types.str; };
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
      # rgb
      hardware.openrgb = mkIf cfg.rgb {
        enable = true;
        motherboard = "amd";
      };
    };
    # audio
    security.rtkit.enable = cfg.audio;
    # ply
    boot = mkIf cfg.ply {
      plymouth.enable = true;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
      ];
    };
  };
}
