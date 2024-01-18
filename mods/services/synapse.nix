{
  config,
  lib,
  ...
}: {
  options.service.web.synapse = lib.mkEnableOption "";
  config = let
    inherit (config.service.web) domain;
    matrix_domain = "matrix." + domain;
    port = 8008;
  in
    lib.mkIf config.service.web.synapse {
      services = {
        matrix-synapse = {
          enable = true;
          withJemalloc = true;
          configureRedisLocally = true;
          settings = {
            server_name = domain;
            public_baseurl = "https://${matrix_domain}";
            redis.enabled = true;
            max_upload_size = "5G";
            suppress_key_server_warning = true;
            allow_guest_access = false;
            enable_registration = false;
            enable_registration_without_verification = false;
            url_preview_enabled = true;
            expire_access_token = true;
            listeners = [
              {
                inherit port;
                bind_addresses = ["127.0.0.1"];
                type = "http";
                tls = false;
                x_forwarded = true;
                resources = [
                  {
                    names = ["client" "federation"];
                    compress = true;
                  }
                ];
              }
            ];
          };
          dataDir = "/storage/volumes/synapse";
        };
        postgresql = {
          ensureUsers = [
            {
              name = "matrix-synapse";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = ["matrix-synapse"];
        };
        nginx.virtualHosts = {
          ${matrix_domain} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:${toString port}";
              "/_synapse/client".proxyPass = "http://127.0.0.1:${toString port}";
            };
          };
          ${domain} = {
            locations = let
              mkWellKnown = data: ''
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
                return 200 '${builtins.toJSON data}';
              '';
            in {
              "= /.well-known/matrix/server".extraConfig = mkWellKnown {"m.server" = "https://${matrix_domain}:443";};
              "= /.well-known/matrix/client".extraConfig = mkWellKnown {"m.homeserver".base_url = "https://${matrix_domain}";};
            };
          };
        };
      };
    };
}
