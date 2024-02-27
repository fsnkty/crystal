{ config, lib, nuke, ... }: {
  options.service.web.nginx.enable = nuke.mkEnable;
  config = lib.mkIf config.service.web.nginx.enable {
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
        genHosts = lib.mapAttrs' (name: value: {
          name = "${name}.${domain}";
          value = lib.mkIf config.service.web.${value}.enable ({
            locations."/".proxyPass =
              "http://localhost:${toString config.service.web.${value}.port}";
          } // ssl);
        });
      in {
        "${domain}" = { root = "/storage/web/public"; } // ssl;
        "wires.${domain}" = { root = "/storage/web/wires"; } // ssl;
        "vault.${domain}".locations."/".extraConfig =
          "proxy_pass_header Authorization;";
        "cloud.${domain}" = { http2 = true; } // ssl;
      } // genHosts {
        tea = "forgejo";
        ana = "grafana";
        vault = "vaultwarden";
        navi = "navidrome";
        qbit = "qbittorrent";
        komga = "komga";
        jelly = "jellyfin";
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
