{ lib, nuke, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) int bool;
  # wtf am i doing.
  inherit (nuke) mkEnable mkDefaultInt;
in
{
  _module.args.nuke = {
    # yep.. takes an int, makes it the default.
    mkDefaultInt =
      dint:
      mkOption {
        default = dint;
        type = int;
      };
    # like `lib.mkEnableOption` but stupid.
    mkEnable = mkOption {
      default = false;
      type = bool;
    };
    # all my web modules just have these options anyway.
    mkWebOpt = port: {
      enable = mkEnable;
      port = mkDefaultInt port;
    };
    # yep.. 
    mkStr = mkOption { type = lib.types.str; };
  };
}
