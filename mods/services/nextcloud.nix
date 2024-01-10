{
  config,
  pkgs,
  lib,
  ...
}: {
  options.local.services.web.nextcloud.enable = lib.mkEnableOption "";
  config = let
    domain = "cloud.${config.local.services.web.domain}";
  in
    lib.mkIf config.local.services.web.nextcloud.enable {
      age.secrets = {
        user_cloud = {
          file = ../../shhh/user_cloud.age;
          owner = "nextcloud";
        };
        cloud_env = {
          file = ../../shhh/cloud_env.age;
          owner = "nextcloud";
        };
      };
      services = {
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud28;
          hostName = domain;
          home = "/storage/volumes/nextcloud";
          
          nginx.recommendedHttpHeaders = true;
          https = true;
          
          config = {
            adminuser = "nuko";
            adminpassFile = config.age.secrets.user_cloud.path; # only set on setup.
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
          };
          phpOptions = {
            "opcache.interned_strings_buffer" = "16";
            "output_buffering" = "off";
          };
          configureRedis = true;
          
          extraOptions = {
            overwriteprotocol = "https";
            trusted_proxies = ["https://${domain}"];
            trusted_domains = ["https://${domain}"];
            default_phone_region = "NZ";
            # service mail setup.
            mail_smtpmode = "smtp";
            mail_sendmailmode = "smtp";
            mail_smtpsecure = "ssl";
            mail_smtphost = "mail.nuko.city";
            mail_smtport = "465";
            mail_smtpauth = 1;
            mail_smtpname = "cloud@nuko.city";
            mail_from_address = "cloud";
          };
          # just the smtp pass.
          secretFile = config.age.secrets.cloud_env.path;
          
          appstoreEnable = false;
          autoUpdateApps.enable = true;
          extraAppsEnable = true;
          extraApps = { inherit (pkgs.nextcloud28Packages.apps) mail calendar bookmarks notes; };
        };
        postgresql = {
          enable = true;
          ensureDatabases = [config.services.nextcloud.config.dbname];
          ensureUsers = [
            {
              name = config.services.nextcloud.config.dbuser;
              ensureDBOwnership = true;
            }
          ];
        };
        nginx.virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          http2 = true;
        };
      };
      systemd.services."nextcloud-setup" = {
        requires = ["postgresql.service"];
        after = ["postgresql.service"];
      };
    };
}
