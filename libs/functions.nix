{
  lib,
  _lib,
  config,
  ...
}:
let
  inherit (lib) mkOption listToAttrs types;
  inherit (types) int bool str;
  inherit (_lib)
    mkEnable
    setInt
    setStr
    mkAssert
    ;
in
{
  _module.args._lib = {
    # for holding info in options.
    setInt =
      dint:
      mkOption {
        default = dint;
        type = int;
        readOnly = true;
      };
    setStr =
      dstr:
      mkOption {
        default = dstr;
        type = str;
        readOnly = true;
      };
    # like `lib.mkEnableOption` but stupid
    mkEnable = mkOption {
      default = false;
      type = bool;
    };
    # all my web modules just have these options anyway
    mkWebOpt = dns: port: {
      enable = mkEnable;
      dns = setStr dns;
      port = setInt port;
    };
    # how this isnt yet in `lib.` is surprising
    genAttrs' = list: f: listToAttrs (map f list);
    # remove some boilerplate from making assertions.
    mkAssert = a: b: [
      {
        assertion = a;
        message = b;
      }
    ];
    assertWeb = mkAssert config._services.nginx "all web services need nginx.";
  };
}
