{
  config,
  lib,
  ...
}:
{
  options.crystal.system.timezone.nz = lib.mkEnableOption "set relavent options for an NZ timezone";
  config = lib.mkIf config.crystal.system.timezone.nz {
    time.timeZone = "Pacific/Auckland";
    i18n = {
      defaultLocale = "en_NZ.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_NZ.UTF-8";
        LC_IDENTIFICATION = "en_NZ.UTF-8";
        LC_MEASUREMENT = "en_NZ.UTF-8";
        LC_MONETARY = "en_NZ.UTF-8";
        LC_NAME = "en_NZ.UTF-8";
        LC_NUMERIC = "en_NZ.UTF-8";
        LC_PAPER = "en_NZ.UTF-8";
        LC_TELEPHONE = "en_NZ.UTF-8";
        LC_TIME = "en_NZ.UTF-8";
      };
    };
  };
}
