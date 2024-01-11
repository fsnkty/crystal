{
  config,
  lib,
  ...
}: {
  options.service.fail2ban = lib.mkEnableOption "";
  config = lib.mkIf config.service.fail2ban {
    services.fail2ban = {
      enable = true;
      bantime-increment = {
        enable = true;
        factor = "16";
      };
    };
  };
}
