{ config, pkgs, lib, ... }: {
  options.service.web.synapse.enable = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.synapse.enable {
    age.secrets.synapse_shared = {
      file = ../../shhh/synapse_shared.age;
      owner = "matrix-synapse";
    };
    services = {
      matrix-synapse = {
        enable = true;
        settings = {
          server_name = config.networking.domain;
          url_preview_enabled = true;
          max_upload_size = "10G";
          registration_shared_secret_path =
            config.age.secrets.synapse_shared.path;
          registration_requires_token = true;
          presence.enabled = false;
          withJemalloc = true;
          enable_metrics = true;
          listeners = [
            {
              bind_addresses = [ "127.0.0.1" ];
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
              tls = false;
              type = "http";
              x_forwarded = true;
            }
            {
              bind_addresses = [ "127.0.0.1" ];
              port = 9118;
              type = "metrics";
              tls = false;
              resources = [ ];
            }
          ];
        };
      };
      nginx = {
        virtualHosts = {
          "matrix.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:8008";
              "/_synapse".proxyPass = "http://127.0.0.1:8008";
            };
          };
          "${config.networking.domain}".locations = let
            mhost = "matrix.${config.networking.domain}";
            formatJson = pkgs.formats.json { };
            extraConfig = ''
              default_type application/json;
              add_header Access-Control-Allow-Origin "*";
            '';
          in {
            "=/.well-known/matrix/server" = {
              alias = formatJson.generate "well-known-matrix-server" {
                "m.server" = "${mhost}:443";
              };
              inherit extraConfig;
            };
            "=/.well-known/matrix/client" = {
              alias = formatJson.generate "well-known-matrix-client" {
                "m.homeserver" = { "base_url" = "https://${mhost}"; };
                "org.matrix.msc3575.proxy" = { "url" = "https://${mhost}"; };
              };
              inherit extraConfig;
            };
          };
        };
      };
    };
  };
}
