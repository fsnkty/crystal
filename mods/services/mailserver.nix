{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.snms.nixosModules.default];
  options.service.mailserver = lib.mkEnableOption "";
  config = lib.mkIf config.service.mailserver {
    age.secrets =
      lib.genAttrs [
        "personal"
        "services"
      ] (name: {
        file = ../../shhh + "/${name}_mail.age";
        owner = "dovecot2";
      });
    mailserver = let
      inherit (config.service.web) domain;
    in {
      enable = true;
      fqdn = "mail.${domain}";
      domains = ["${domain}"];
      loginAccounts = let
        inherit (config.age.secrets) personal services;
      in {
        "host@${domain}" = {
          hashedPasswordFile = personal.path;
          aliases = ["me@${domain}" "acme@${domain}" "admin@${domain}"];
        };
        "cloud@${domain}".hashedPasswordFile = services.path;
        "vault@${domain}".hashedPasswordFile = services.path;
      };
      certificateScheme = "acme-nginx";
    };
  };
}
