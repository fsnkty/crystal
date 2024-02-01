{ config, lib, ... }:
{
  options.service = {
    fail2ban = lib.mkEnableOption "";
    postgres = lib.mkEnableOption "";
    openssh = lib.mkEnableOption "";
  };
  config =
    let
      inherit (lib) mkIf;
      inherit (config.service) fail2ban postgres openssh;
    in
    {
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
        openssh = mkIf openssh {
          enable = true;
          openFirewall = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };
        };
      };
    };
}
