{
  config,
  lib,
  ...
}: {
  options.service.web.synapse = lib.mkEnableOption "";
  config = let
    domain = config.service.web.domain;
    matrixdomain = "matrix." + domain;
  in
    lib.mkIf config.service.web.synapse {
      services = {
        matrix-synapse = {
          enable = true;
          withJemalloc = true;
          settings = {
            server_name = domain;
            redis.enable = true;
            public_baseurl = "https://" + matrixdomain;
            max_upload_size = "5G";
            enable_registration = false;
            listeners = [
              {
                port = 8008;
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
        nginx.virtualHosts = let
          serverConfig."m.server" = matrixdomain + ":443";
          clientConfig."m.homeserver".base_url = "https://" + domain;
          mkWellKnown = data: ''
            default_type application/json;
            return 200 '${builtins.toJSON data}';
          '';
        in {
          ${matrixdomain} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/".extraConfig = ''return 404; '';
              "~ ^(/_matrix|/_synapse/client)".proxyPass = "http://127.0.0.1:8008";
            };
          };
          ${domain} = {
            locations = {
              "= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
              "= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
            };
          };
        };
      };
    };
}
