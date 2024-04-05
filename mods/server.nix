{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.server;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{

  options.server = {
    security = mkEnableOption "sec defaults";
    headless = mkEnableOption "no head";
    tailscale = mkEnableOption "tail defaults";
    samba = mkEnableOption "samba share";
  };

  config = mkMerge [
    (mkIf cfg.security {
      security.sudo.execWheelOnly = true;
      users.users.root = {
        hashedPassword = lib.mkDefault "!";
        shell = lib.mkForce pkgs.shadow;
      };
      networking.firewall.enable = true;
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
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
        kernelParams = [ "panic=1" "boot.panic_on_fail" ];
        loader.timeout = 0;
      };
      services = {
        openssh = {
          enable = true;
          settings.AllowUsers = [ config.users.users.main.name ];
          hostKeys = [{
            comment = "library host";
            path = "/etc/ssh/library_ed25519_key"; # library priv
            type = "ed25519";
          }];
        };
      };
    })
    (mkIf cfg.tailscale {
      networking = {
        nameservers = [ "100.100.100.100" ];
        search = [ "tail44d12a.ts.net" ];
        firewall.trustedInterfaces = [ "tailscale0" ];
      };
      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "both";
        authKeyFile = "/keys/tailscale";
      };
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
          "root" = {
            path = "/";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force user" = "fsnkty";
          };
        };
      };
    })
  ];
}
