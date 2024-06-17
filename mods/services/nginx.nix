{
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._services.nginx = _lib.mkEnable;
  config =
    let
      inherit (lib) mkIf;
      inherit (config.networking) domain;
      genHosts =
        i:
        _lib.genAttrs' i (
          x:
          let
            inherit (config._services.web.${x}) enable dns port;
          in
          {
            name = "${dns}.${domain}";
            value = {
              locations."/".proxyPass = mkIf enable "http://localhost:${toString port}";
              inherit forceSSL enableACME;
            };
          }
        );
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin "*";
      '';
    in
    mkIf config._services.nginx {
      services.nginx = {
        enable = true;
        virtualHosts = lib.mkMerge [
          {
            "${domain}" = {
              root = "/storage/web/shimeji.cafe";
              locations = mkIf config._services.synapse {
                "=/.well-known/matrix/server" = {
                  alias = (pkgs.formats.json { }).generate "well-known-matrix-server" {
                    "m.server" = "matrix.${domain}:443";
                  };
                  inherit extraConfig;
                };
                "=/.well-known/matrix/client" = {
                  alias = (pkgs.formats.json { }).generate "well-known-matrix-client" {
                    "m.homeserver"."base_url" = "https://matrix.${domain}";
                    "org.matrix.msc3575.proxy"."url" = "https://matrix.${domain}";
                  };
                  inherit extraConfig;
                };
              };
              inherit forceSSL enableACME;
            };
            "matrix.${domain}" = mkIf config._services.synapse {
              locations = {
                "/_matrix".proxyPass = "http://127.0.0.1:8008";
                "/_synapse".proxyPass = "http://127.0.0.1:8008";
              };
              inherit forceSSL enableACME;
            };
            "wires.${domain}" = {
              root = "/storage/web/wires";
              inherit forceSSL enableACME;
            };
            "cloud.${domain}" = mkIf config._services.web.nextcloud.enable { inherit forceSSL enableACME; };
            "vault.${domain}".locations."/".extraConfig = mkIf config._services.web.vaultwarden.enable "proxy_pass_header Authorization;";
          }
          (genHosts [
            "vaultwarden"
            "navidrome"
            "qbittorrent"
            "komga"
            "jellyfin"
          ])
        ];
        recommendedBrotliSettings = true;
        recommendedProxySettings = true;
        recommendedZstdSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedTlsSettings = true;
        commonHttpConfig = ''
          real_ip_header CF-Connecting-IP;
          add_header 'Referrer-Policy' 'origin-when-cross-origin';
        '';
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "admin+acme@${domain}";
      };
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      users.users.nginx.extraGroups = [ "acme" ];
    };
}
