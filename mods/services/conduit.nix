{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.service.web.conduit = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.conduit {
    services = {
      matrix-conduit = {
        enable = true;
        settings.global = {
          server_name = "${config.service.web.domain}";
          address = "0.0.0.0";
          enable_lightning_bolt = false;
        };
      };
      nginx = {
        virtualHosts = {
          "matrix.${config.service.web.domain}" = {
            forceSSL = true;
            enableACME = true;
            listen = [
              {
                addr = "0.0.0.0";
                port = 443;
                ssl = true;
              }
            ];
            locations."/_matrix/" = {
              proxyPass = "http://backend_conduit$request_uri";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_buffering off;
              '';
            };
            extraConfig = "merge_slashes off;";
          };
          "${config.service.web.domain}".locations =
            let
              mhost = "matrix.${config.service.web.domain}";
              formatJson = pkgs.formats.json { };
              extraConfig = ''
                default_type application/json;
                add_header Access-Control-Allow-Origin "*";
              '';
            in
            {
              "=/.well-known/matrix/server" = {
                alias = formatJson.generate "well-known-matrix-server" { "m.server" = "${mhost}:443"; };
                inherit extraConfig;
              };
              "=/.well-known/matrix/client" = {
                alias = formatJson.generate "well-known-matrix-client" {
                  "m.homeserver" = {
                    "base_url" = "https://${mhost}";
                  };
                  "org.matrix.msc3575.proxy" = {
                    "url" = "https://${mhost}";
                  };
                };
                inherit extraConfig;
              };
            };
        };
        upstreams."backend_conduit".servers = {
          "0.0.0.0:${toString config.services.matrix-conduit.settings.global.port}" = { };
        };
      };
    };
  };
}
