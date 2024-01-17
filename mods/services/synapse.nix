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
          settings = {
            server_name = domain;
            public_baseurl = "https://" + matrixdomain;
            max_upload_size = "5G";
            suppress_key_server_warning = true;
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
                    compress = false;
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
           mkWellKnown = data: ''
             add_header Content-Type application/json;
             add_header Access-Control-Allow-Origin *;
             return 200 '${builtins.toJSON data}';
           '';
        in {
          ${matrixdomain} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/_matrix".proxyPass = "http://127.0.0.1:8008";
              "/_synapse/client".proxyPass = "http://127.0.0.1:8008";
              "= /.well-known/matrix/server".extraConfig = mkWellKnown {"m.server" = "https://matrix.nuko.city:443";};
              "= /.well-known/matrix/client".extraConfig = mkWellKnown {"m.homeserver".base_url = "https://matrix.nuko.city";};
            };
          };
          ${domain} = {
            locations = {
              "= /.well-known/matrix/server".extraConfig = mkWellKnown {"m.server" = "https://matrix.nuko.city:443";};
              "= /.well-known/matrix/client".extraConfig = mkWellKnown {"m.homeserver".base_url = "https://matrix.nuko.city";};
            };
          };
        };
      };
    };
}
