{ config, lib, ... }: {
  options.service.web.enable = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${config.networking.domain}";
    };
    services.nginx = {
      enable = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
      '';
      recommendedZstdSettings = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      virtualHosts = let
        inherit (config.networking) domain;
        genHosts = lib.mapAttrs' (name: set: {
          name = "${name}.${domain}";
          value = lib.mkIf config.service.web.${name} ({
            locations."/".proxyPass = "http://localhost:${toString set.port}";
          } // ssl);
        });
        ssl = {
          forceSSL = true;
          enableACME = true;
        };
      in {
        "${domain}" = { root = "/storage/web/public"; } // ssl;
        "wires.${domain}" = { root = "/storage/web/wires"; } // ssl;
        "cloud.${domain}" = { http2 = true; } // ssl;
        "vault.${domain}".locations."/".extraConfig =
          "proxy_pass_header Authorization;";
      } // genHosts {
        tea = { port = config.services.forgejo.settings.server.HTTP_PORT; };
        ana = { port = config.services.grafana.settings.server.http_port; };
        vault = { port = config.services.vaultwarden.config.ROCKET_PORT; };
        navi = { port = config.services.navidrome.settings.Port; };
        qbit = { port = config.services.qbittorrent.webuiPort; };
        komga = { port = config.services.komga.port; };
        jelly = { port = 8096; };
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
