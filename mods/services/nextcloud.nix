{
  config,
  pkgs,
  lib,
  nuke,
  ...
}:
{
  options.service.web.nextcloud.enable = nuke.mkEnable;
  config = lib.mkIf config.service.web.nextcloud.enable {
    age.secrets =
      lib.genAttrs
        [
          "user_cloud"
          "cloud_env"
        ]
        (name: {
          file = ../../shhh + "/${name}.age";
          owner = "nextcloud";
        });
    services.nextcloud =
      let
        inherit (config.networking) domain;
        inherit (config.age.secrets) user_cloud cloud_env;
      in
      {
        enable = true;
        package = pkgs.nextcloud28;
        database.createLocally = true;
        configureRedis = true;
        config = {
          adminuser = "nuko";
          adminpassFile = user_cloud.path; # only set on setup.
          dbtype = "pgsql";
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "16";
          "output_buffering" = "off";
        };
        # just the smtp pass.
        secretFile = cloud_env.path;
        settings = {
          mail_smtpmode = "smtp";
          mail_sendmailmode = "smtp";
          mail_smtpsecure = "ssl";
          mail_smtphost = "mail.${domain}";
          mail_smtpport = "465";
          mail_smtpauth = 1;
          mail_smtpname = "cloud@${domain}";
          mail_from_address = "cloud";
          mail_domain = domain;
          default_phone_region = "NZ";
          overwriteprotocol = "https";
          trusted_proxies = [ "https://cloud.${domain}" ];
          trusted_domains = [ "https://cloud.${domain}" ];
        };
        hostName = "cloud.${domain}";
        nginx.recommendedHttpHeaders = true;
        https = true;
      };
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
