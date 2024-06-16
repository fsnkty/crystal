{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.web.komga = _lib.mkWebOpt "komga" 8097;
  config = lib.mkIf config._services.web.komga.enable {
    assertions = _lib.assertWeb;
    services.komga = {
      inherit (config._services.web.komga) enable port;
      group = "media";
    };
  };
}
