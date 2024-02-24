{ config, lib, ... }: {
  options.service.web = {
    enable = lib.mkEnableOption "";
    domain = lib.mkOption { type = lib.types.str; };
  };
  config = lib.mkIf config.service.web.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 9090 ];
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
        ssl = {
          forceSSL = true;
          enableACME = true;
        };
        genHosts = lib.mapAttrs' (name: set: {
          name = "${name}.${domain}";
          value = lib.mkIf set.opt ({
            locations."/".proxyPass = "http://localhost:${toString set.port}";
          } // ssl);
        });
      in {
        "${domain}" = { root = "/storage/web/public"; } // ssl;
        "wires.${domain}" = { root = "/storage/web/wires"; } // ssl;
        "cloud.${domain}" = { http2 = true; } // ssl;
        "vault.${domain}".locations."/".extraConfig = "proxy_pass_header Authorization;";
      } // genHosts {
        vault = {
          opt = config.service.web.vaultwarden;
          port = config.services.vaultwarden.config.ROCKET_PORT;
        };
        tea = {
          opt = config.service.web.forgejo;
          port = config.services.forgejo.settings.server.HTTP_PORT;
        };
        ana = {
          opt = config.service.web.grafana;
          port = config.services.grafana.settings.server.http_port;
        };
        navi = {
          opt = config.service.web.navidrome;
          port = config.services.navidrome.settings.Port;
        };
        komga = {
          opt = config.service.web.komga;
          port = config.services.komga.port;
        };
        qbit = {
          opt = config.service.web.qbit;
          port = config.services.qbittorrent.webuiPort;
        };
        jelly = {
          opt = config.service.web.jellyfin;
          port = 8096;
        };
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
