{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  options.service.web.matrixhome = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.matrixhome {
    services =
      let
        server_name = "${config.service.web.domain}";
        matrix_hostname = "matrix.${server_name}";
        address = "0.0.0.0";
      in
      {
        matrix-conduit = {
          enable = true;
          package = inputs.conduit.packages.${pkgs.system}.default;
          settings.global = {
            inherit server_name address;
            enable_lightning_bolt = false;
          };
        };
        nginx = {
          virtualHosts = {
            "${matrix_hostname}" = {
              forceSSL = true;
              enableACME = true;
              listen = [
                {
                  addr = address;
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
            "${server_name}".locations =
              let
                formatJson = pkgs.formats.json { };
                extraConfig = ''
                  default_type application/json;
                  add_header Access-Control-Allow-Origin "*";
                '';
              in
              {
                "=/.well-known/matrix/server" = {
                  alias = formatJson.generate "well-known-matrix-server" { "m.server" = "${matrix_hostname}:443"; };
                  inherit extraConfig;
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
                  inherit extraConfig;
                };
              };
          };
          upstreams."backend_conduit".servers = {
            "${address}:${toString config.services.matrix-conduit.settings.global.port}" = { };
          };
        };
      };
  };
}
