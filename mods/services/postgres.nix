{
  config,
  lib,
  ...
}: {
  options.service.postgres = lib.mkEnableOption "";
  config = lib.mkIf config.service.postgres {
    services.postgresql = {
      enable = true;
      dataDir = "/storage/volumes/postgres";
      initdbArgs = [
        "--no-locale"
        "--encoding=UTF8"
      ];
    };
  };
}
