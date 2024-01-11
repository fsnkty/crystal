{
  config,
  lib,
  ...
}: {
  options.service.mailserver = lib.mkEnableOption "";
  config = let
    baseDomain = "${config.service.web.domain}";
  in
    lib.mkIf config.service.mailserver {
      age.secrets = {
        personal = {
          file = ../../shhh/personal_mail.age;
          owner = "dovecot2";
        };
        services = {
          file = ../../shhh/services_mail.age;
          owner = "dovecot2";
        };
      };
      mailserver = {
        enable = true;
        fqdn = "mail.${baseDomain}";
        domains = ["${baseDomain}"];

        loginAccounts = {
          "host@${baseDomain}" = {
            hashedPasswordFile = config.age.secrets.personal.path;
            aliases = ["me@${baseDomain}" "acme@${baseDomain}" "admin@${baseDomain}"];
          };
          "cloud@${baseDomain}".hashedPasswordFile = config.age.secrets.services.path;
          "vault@${baseDomain}".hashedPasswordFile = config.age.secrets.services.path;
        };
        certificateScheme = "acme-nginx";
      };
    };
}
