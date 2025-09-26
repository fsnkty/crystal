{ config, lib, ... }:
let
  cfg = config.server.networking;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.server.networking = {
    library = mkEnableOption "Library server configuration";
    nginx = mkEnableOption "Nginx web server";
    samba = mkEnableOption "Samba file sharing service";
    ssh = {
      enable = mkEnableOption "OpenSSH server for remote access";
      headless = mkEnableOption "Disable all gettys, serial consoles & emergency mode";
    };
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
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "fsnkty";
          };
          "home" = {
            path = "/home/fsnkty";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "fsnkty";
          };
        };
      };
    })
    (mkIf cfg.ssh.enable {
      services = {
        openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            AllowUsers = [ config.users.users.main.name ];
          };
          hostKeys = [{
            comment = "library host";
            path = "/etc/ssh/library_ed25519_key"; # library priv
            type = "ed25519";
          }];
        };
      };
    })
    (mkIf cfg.ssh.headless {
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
        kernelParams = [ "panic=1" "boot.panic_on_fail" ];
        loader.timeout = 0;
      };
    })
  ];
}

