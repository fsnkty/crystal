{ config, pkgs, lib, ... }: {
  options.service.web.synapse = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.synapse {
    age.secrets = {
      discord_bridge = {
        file = ../../shhh/discord_bridge.age;
        owner = "matrix-appservice-discord";
      };
      synapse_shared = {
        file = ../../shhh/synapse_shared.age;
        owner = "matrix-synapse";
      };
    };
    services = {
      matrix-synapse = {
        enable = true;
        settings = {
          server_name = config.service.web.domain;
          url_preview_enabled = true;
          max_upload_size = "10G";
          registration_shared_secret_path = config.age.secrets.synapse_shared.path;
          registration_requires_token = true;
        };
      };
      nginx = {
        virtualHosts = {
          "matrix.${config.service.web.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:8008";
              "/_synapse".proxyPass = "http://127.0.0.1:8008";
            };
          };
          "${config.service.web.domain}".locations = let
            mhost = "matrix.${config.service.web.domain}";
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
