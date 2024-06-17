{
  config,
  _lib,
  lib,
  ...
}:
{
  options._services.synapse = _lib.mkEnable;
  config = lib.mkIf config._services.synapse {
    assertions = _lib.assertWeb;
    deployment.keys."synapse_shared" = {
      keyCommand = [
        "age"
        "-i"
        "/keys/deploy/library"
        "-d"
        "assets/age/synapse_shared.age"
      ];
      destDir = "/keys";
      user = "matrix-synapse";
      group = "matrix-synapse";
    };
    services = {
      postgresql.enable = true;
      matrix-synapse = {
        enable = true;
        settings = {
          server_name = config.networking.domain;
          max_upload_size = "100M";
          url_preview_enabled = true;
          presence.enabled = true;
          withJemalloc = true;
          registration_shared_secret_path = "/keys/synapse_shared";
          registration_requires_token = true;
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
            ];
        };
      };
    };
  };
}
