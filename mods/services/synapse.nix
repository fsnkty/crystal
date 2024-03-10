{
  config,
  pkgs,
  lib,
  nuke,
  ...
}:
{
  options.service.web.synapse.enable = nuke.mkEnable;
  config = lib.mkIf config.service.web.synapse.enable {
    age.secrets.synapse_shared = {
      file = ../../shhh/synapse_shared.age;
      owner = "matrix-synapse";
    };
    services =
      let
        inherit (config.networking) domain;
      in
      {
        matrix-synapse = {
          enable = true;
          settings = {
            server_name = domain;
            url_preview_enabled = true;
            max_upload_size = "10G";
            registration_shared_secret_path = config.age.secrets.synapse_shared.path;
            registration_requires_token = true;
            presence.enabled = false;
            withJemalloc = true;
            enable_metrics = true;
            listeners =
              let
                tls = false;
                bind_addresses = [ "127.0.0.1" ];
              in
              [
                {
                  inherit tls bind_addresses;
                  port = 8008;
                  resources = [
                    {
                      compress = true;
                      names = [ "client" ];
                    }
                    {
                      compress = false;
                      names = [ "federation" ];
                    }
                  ];
                  type = "http";
                  x_forwarded = true;
                }
                {
                  inherit tls bind_addresses;
                  port = 9118;
                  type = "metrics";
                  resources = [ ];
                }
              ];
          };
        };
        nginx.virtualHosts = {
          "matrix.${domain}" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:8008";
              "/_synapse".proxyPass = "http://127.0.0.1:8008";
            };
          };
          "${domain}".locations =
            let
              extraConfig = ''
                default_type application/json;
                add_header Access-Control-Allow-Origin "*";
              '';
              inherit (pkgs.formats) json;
            in
            {
              "=/.well-known/matrix/server" = {
                alias = (json { }).generate "well-known-matrix-server" { "m.server" = "matrix.${domain}:443"; };
                inherit extraConfig;
              };
              "=/.well-known/matrix/client" = {
                alias = (json { }).generate "well-known-matrix-client" {
                  "m.homeserver" = {
                    "base_url" = "https://matrix.${domain}";
                  };
                  "org.matrix.msc3575.proxy" = {
                    "url" = "https://matrix.${domain}";
                  };
                };
                inherit extraConfig;
              };
            };
        };
      };
  };
}
