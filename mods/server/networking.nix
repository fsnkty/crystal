{ config, lib, ... }:
let
  cfg = config.server.networking;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.server.networking = {
    nginx = mkEnableOption "Nginx web server";
    samba = mkEnableOption "Samba file sharing service";
    headless = mkEnableOption "Disable all gettys, serial consoles & emergency mode";
  };
  config = mkMerge [
    (mkIf cfg.nginx {
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedBrotliSettings = true;
        commonHttpConfig = ''
          real_ip_header CF-Connecting-IP;
          add_header 'Referrer-Policy' 'origin-when-cross-origin';
        '';
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = "fsnkty@shimeji.cafe";
        certs = {
          "shimeji.cafe" = {
            domain = "*.shimeji.cafe";
            group = "nginx";
            dnsProvider = "cloudflare";
            environmentFile = "/keys/cloudflare";
          };
        };
      };
      networking.firewall.allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
      users.users.nginx.extraGroups = [ "acme" ];
    })
    (mkIf cfg.samba {
      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "invalid users" = [ "root" ];
            "passwd program" = "/run/wrappers/bin/passwd %u";
            security = "user";
          };
          "storage" = {
            path = "/storage";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "fsnkty";
          };
          "amber" = {
            path = "/storage/amber";
            "read only" = "no";
            "quest ok" = "no";
            "force user" = "amber";
          };
        };
      };
    })
    (mkIf cfg.headless {
      systemd = {
        services = {
          "getty@tty1".enable = false;
          "autovt@".enable = false;
          "serial-getty@ttyS0".enable = lib.mkDefault false;
          "serial-getty@hvc0".enable = false;
        };
        enableEmergencyMode = false;
      };
      boot = {
        kernelParams = [
          "panic=1"
          "boot.panic_on_fail"
        ];
        loader.timeout = 0;
      };
    })
  ];
}
