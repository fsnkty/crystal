
{
  config,
  lib,
  ...
}: {
  options.service = {
    fail2ban = lib.mkEnableOption "";
    postgres = lib.mkEnableOption "";
  };
  config = {
    services = {
      fail2ban = lib.mkIf config.service.fail2ban {
        enable = true;
        bantime-increment = {
          enable = true;
          factor = "16";
        };
      };
      postgresql = lib.mkIf config.service.postgres {
        enable = true;
        dataDir = "/storage/volumes/postgres";
        initdbArgs = [
          "--no-locale"
          "--encoding=UTF8"
        ];
      };
    };
  };
}
