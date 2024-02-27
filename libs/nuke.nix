{ lib, ... }: {
  _module.args.nuke = {
    mkDefaultInt =
      port: lib.mkOption {
        default = port;
        type = lib.types.int;
      };
  };
}
