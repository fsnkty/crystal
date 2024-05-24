{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._services.web.nextcloud = _lib.mkWebOpt "cloud" 0;
  config =
    let
      inherit (config._services.web.nextcloud) enable dns;
      inherit (config.networking) domain;
    in
    lib.mkIf enable {
      assertions = _lib.assertWeb;
      age.secrets.user_cloud = {
        file = ../../../assets/age/user_cloud.age;
        owner = "nextcloud";
      };
      services.nextcloud = {
        inherit enable;
        package = pkgs.nextcloud29;
        database.createLocally = true;
        configureRedis = true;
        config = {
          adminuser = "nuko";
          adminpassFile = config.age.secrets.user_cloud.path; # only set on setup.
          dbtype = "pgsql";
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
          "output_buffering" = "off";
        };
        settings = {
          default_phone_region = "NZ";
          overwriteprotocol = "https";
          trusted_proxies = [ "https://${dns}.${domain}" ];
          trusted_domains = [ "https://${dns}.${domain}" ];
        };
        hostName = "cloud.${domain}";
        nginx.recommendedHttpHeaders = true;
        https = true;
      };
    };
}
