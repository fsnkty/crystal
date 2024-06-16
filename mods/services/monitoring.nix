{
  config,
  _lib,
  lib,
  ...
}:
# needs nginx
{
  options._services = {
    prometheus = _lib.mkEnable;
    web.grafana = _lib.mkWebOpt "ana" 8094;
  };
  config =
    let
      inherit (lib) mkIf;
      inherit (config._services.web.grafana) enable port dns;
    in
    {
      services = {
        grafana = mkIf enable {
          inherit enable;
          settings.server = {
            http_addr = "127.0.0.1";
            http_port = port;
            domain = "${dns}.${config.networking.domain}";
          };
        };
        prometheus = mkIf config._services.prometheus {
          enable = true;
          exporters = {
            node = {
              enable = true;
              enabledCollectors = [ "systemd" ];
            };
          };
          scrapeConfigs = [
            {
              job_name = "library";
              static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
            }
          ];
        };
      };
    };
}
