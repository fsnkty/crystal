{
  inputs,
  config,
  lib,
  nuke,
  ...
}:
{
  imports = [ inputs.snms.nixosModules.default ];
  options.service.mailserver = nuke.mkEnable;
  config = lib.mkIf config.service.mailserver {
    age.secrets =
      lib.genAttrs
        [
          "personal"
          "services"
        ]
        (name: {
          file = ../../shhh + "/${name}_mail.age";
          owner = "dovecot2";
        });
    mailserver =
      let
        inherit (config.networking) domain;
        inherit (config.age.secrets) personal services;
      in
      {
        enable = true;
        fqdn = "mail.${domain}";
        domains = [ "${domain}" ];
        loginAccounts = {
          "nuko@${domain}" = {
            hashedPasswordFile = personal.path;
            aliases = [
              "host@${domain}"
              "acme@${domain}"
              "admin@${domain}"
            ];
          };
          "all@${domain}" = {
            hashedPasswordFile = personal.path;
            aliases = [ "@${domain}" ];
          };
          "cloud@${domain}".hashedPasswordFile = services.path;
          "vault@${domain}".hashedPasswordFile = services.path;
        };
        certificateScheme = "acme-nginx";
      };
    services.dovecot2.sieve.extensions = [ "fileinto" ];
  };
}
