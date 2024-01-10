{
  config,
  lib,
  ...
}: {
  options.local.services.postgres.enable = lib.mkEnableOption "";
  config = lib.mkIf config.local.services.postgres.enable {
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
