{
  config,
  lib,
  nuke,
  ...
}:
let
  inherit (config.networking) domain;
  inherit (lib) mkIf mapAttrs';
  cw = config.service.web;
in
{
  options.service.web.nginx.enable = nuke.mkEnable;
  config = mkIf cw.nginx.enable {
    services.nginx = {
      enable = true;
      recommendedZstdSettings = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
      commonHttpConfig = ''
        real_ip_header CF-Connecting-IP;
        add_header 'Referrer-Policy' 'origin-when-cross-origin';
      '';
      virtualHosts =
        let
          ssl = {
            forceSSL = true;
            enableACME = true;
          };
          gen = mapAttrs' (
            n: v: {
              name = "${n}.${domain}";
              value = mkIf cw.${v}.enable (
                { locations."/".proxyPass = "http://localhost:${toString cw.${v}.port}"; } // ssl
              );
            }
          );
        in
        {
          "${domain}" = {
            root = "/storage/web/public";
          } // ssl;
          "wires.${domain}" = {
            root = "/storage/web/wires";
          } // ssl;
          "vault.${domain}".locations."/".extraConfig = "proxy_pass_header Authorization;";
          "cloud.${domain}" = ssl;
        }
        // gen {
          tea = "forgejo";
          ana = "grafana";
          vault = "vaultwarden";
          navi = "navidrome";
          qbit = "qbittorrent";
          komga = "komga";
          jelly = "jellyfin";
        };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@${domain}";
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
