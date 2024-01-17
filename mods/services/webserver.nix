{
  config,
  lib,
  ...
}: {
  options.service.web = {
    enable = lib.mkEnableOption "";
    domain = lib.mkOption {type = lib.types.str;};
  };
  config = let
    domain = "${config.service.web.domain}";
  in
    lib.mkIf config.service.web.enable {
      networking.firewall.allowedTCPPorts = [80 443 8080];
      security.acme = {
        acceptTerms = true;
        defaults.email = "acme@${domain}";
      };
      services.nginx = {
        enable = true;
        commonHttpConfig = ''
          real_ip_header CF-Connecting-IP;
          #add_header 'Referrer-Policy' 'origin-when-cross-origin';
          #add_header X-Frame-Options DENY;
          #add_header X-Content-Type-Options nosniff;
          #add_header Access-Control-Allow-Origin *;
        '';
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        virtualHosts."${domain}" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = [domain];
          root = "/storage/volumes/website/public";
        };
        virtualHosts."wires.${domain}" = {
          forceSSL = true;
          enableACME = true;
          root = "/storage/volumes/website/wires";
        };
      };
    };
}
