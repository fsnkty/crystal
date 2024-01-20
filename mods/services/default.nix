{
  config,
  lib,
  ...
}: {
  options.service = {
    fail2ban = lib.mkEnableOption "";
    postgres = lib.mkEnableOption "";
  };
  config = let
    inherit (lib) mkIf;
    inherit (config.service) fail2ban postgres;
  in {
    services = {
      fail2ban = mkIf fail2ban {
        enable = true;
        bantime-increment = {
          enable = true;
          factor = "16";
        };
      };
      postgresql = mkIf postgres {
        enable = true;
        dataDir = "/storage/volumes/postgres";
      };
    };
  };
}
