{ config, lib, ... }: {
  options.service.web = {
    enable = lib.mkEnableOption "";
    domain = lib.mkOption { type = lib.types.str; };
  };
  config = lib.mkIf config.service.web.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${config.service.web.domain}";
    };
    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
      '';
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      virtualHosts."${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        root = "/storage/web/public";
      };
      virtualHosts."wires.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        root = "/storage/web/wires";
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
