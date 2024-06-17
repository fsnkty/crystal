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
      deployment.keys."user_cloud" = {
        keyCommand = [
          "age"
          "-i"
          "/keys/deploy/library"
          "-d"
          "assets/age/user_cloud.age"
        ];
        destDir = "/keys";
        user = "nextcloud";
        group = "nextcloud";
      };
      assertions = _lib.assertWeb;
      services.nextcloud = {
        inherit enable;
        package = pkgs.nextcloud29;
        configureRedis = true;
        config = {
          adminuser = config.users.users.main.name;
          adminpassFile = "/keys/user_cloud"; # only set on setup.
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
          "output_buffering" = "off";
        };
        settings = {
          default_phone_region = "NZ";
          overwriteprotocol = "https";
          trusted_proxies = [ "104.21.63.104" ];
          trusted_domains = [ "${dns}.${domain}" ];
          "overwrite.cli.url" = "https://${dns}.${domain}";
        };
        hostName = "cloud.${domain}";
        nginx.recommendedHttpHeaders = true;
        https = true;
      };
    };
}
