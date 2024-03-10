{
  config,
  lib,
  nuke,
  ...
}:
{
  options.service.web.grafana = nuke.mkWebOpt 8094;
  config = lib.mkIf config.service.web.grafana.enable {
    age.secrets."user_cloud_pom" = {
      file = ../../shhh/user_cloud_pom.age;
      owner = "nextcloud-exporter";
    };
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = config.service.web.grafana.port;
            domain = "ana.shimeji.cafe";
          };
        };
      };
      prometheus = {
        enable = true;
        exporters = {
          zfs.enable = true;
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
          };
          nextcloud = {
            enable = true;
            username = "nuko";
            passwordFile = config.age.secrets.user_cloud_pom.path;
            url = "https://cloud.shimeji.cafe";
          };
          nginx.enable = true;
        };
        scrapeConfigs = [
          {
            job_name = "library";
            static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
          }
          {
            job_name = "nextcloud";
            static_configs = [ { targets = [ "127.0.0.1:9205" ]; } ];
          }
          {
            job_name = "zfs";
            static_configs = [ { targets = [ "127.0.0.1:9134" ]; } ];
          }
          {
            job_name = "nginx";
            static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
          }
          {
            job_name = "synapse";
            metrics_path = "/_synapse/metrics";
            static_configs = [ { targets = [ "127.0.0.1:9118" ]; } ];
          }
        ];
      };
    };
  };
}
