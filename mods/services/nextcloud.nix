{ config, pkgs, lib, nuke, ... }: {
  options.service.web.nextcloud.enable = nuke.mkEnable;
  config = lib.mkIf config.service.web.nextcloud.enable {
    age.secrets = lib.genAttrs [ "user_cloud" "cloud_env" ] (name: {
      file = ../../shhh + "/${name}.age";
      owner = "nextcloud";
    });
    services = {
      nextcloud = let inherit (config.networking) domain;
      in {
        enable = true;
        package = pkgs.nextcloud28;
        hostName = "cloud.${domain}";
        nginx.recommendedHttpHeaders = true;
        https = true;
        config = {
          adminuser = "nuko";
          adminpassFile =
            config.age.secrets.user_cloud.path; # only set on setup.
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
          trusted_proxies = [ "https://cloud.${domain}" ];
          trusted_domains = [ "https://cloud.${domain}" ];
          default_phone_region = "NZ";
          mail_smtpmode = "smtp";
          mail_sendmailmode = "smtp";
          mail_smtpsecure = "ssl";
          mail_smtphost = "mail.${domain}";
          mail_smtpport = "465";
          mail_smtpauth = 1;
          mail_smtpname = "cloud@${domain}";
          mail_from_address = "cloud";
          mail_domain = domain;
        };
        # just the smtp pass.
        secretFile = config.age.secrets.cloud_env.path;
        appstoreEnable = false;
        autoUpdateApps.enable = true;
        extraAppsEnable = true;
        extraApps = {
          inherit (pkgs.nextcloud28Packages.apps) mail calendar bookmarks notes;
        };
      };
      postgresql = {
        ensureDatabases = [ config.services.nextcloud.config.dbname ];
        ensureUsers = [{
          name = config.services.nextcloud.config.dbuser;
          ensureDBOwnership = true;
        }];
      };
    };
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };
}
