{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options.service.web.matrixhome = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.matrixhome {
    services = let
      server_name = "${config.service.web.domain}";
      matrix_hostname = "matrix.${server_name}";
    in {
      matrix-conduit = {
        enable = true;
        package = inputs.conduit.packages.${pkgs.system}.default;
        settings.global = {
          inherit server_name;
          address = "0.0.0.0";
        };
      };
      nginx = {
        virtualHosts = {
          "${matrix_hostname}" = {
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
            extraConfig = ''merge_slashes off;'';
          };
          "${server_name}".locations = let
            formatJson = pkgs.formats.json {};
          in {
            "=/.well-known/matrix/server" = {
              alias = formatJson.generate "well-known-matrix-server" {
                "m.server" = "${matrix_hostname}:443";
              };
              extraConfig = ''
                default_type application/json;
                add_header Access-Control-Allow-Origin "*";
              '';
            };
            "=/.well-known/matrix/client" = {
              alias = formatJson.generate "well-known-matrix-client" {
                "m.homeserver" = {
                  "base_url" = "https://${matrix_hostname}";
                };
                "org.matrix.msc3575.proxy" = {
                  "url" = "https://${matrix_hostname}";
                };
              };
              extraConfig = ''
                default_type application/json;
                add_header Access-Control-Allow-Origin "*";
              '';
            };
          };
        };
        upstreams."backend_conduit".servers = {
          "0.0.0.0:${toString config.services.matrix-conduit.settings.global.port}" = {};
        };
      };
    };
  };
}
