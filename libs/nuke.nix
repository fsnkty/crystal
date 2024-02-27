{ lib, ... }: {
  _module.args.nuke = {
    mkDefaultInt =
      port: lib.mkOption {
        default = port;
        type = lib.types.int;
      };
    mkEnable =
      lib.mkOption {
      default = false;
      type = lib.types.bool;
      };
  };
}
