{ config, lib, ... }: {
  options.service.web.vaultwarden = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.vaultwarden {
    age.secrets.vault_env = {
      file = ../../shhh/vault_env.age;
      owner = "vaultwarden";
    };
    services = {
      vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "https://vault.${config.service.web.domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = 8222;
          ROCKET_LOG = "critical";
          SMTP_HOST = "mail.${config.service.web.domain}";
          SMPT_PORT = 465;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "vault@${config.service.web.domain}";
          SMTP_FROM_NAME =
            "vault.${config.service.web.domain} Vaultwarden server";
          SMTP_USERNAME = "vault@${config.service.web.domain}";
        };
        environmentFile = config.age.secrets.vault_env.path;
      };
      nginx.virtualHosts."vault.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8222";
          extraConfig = "proxy_pass_header Authorization;";
        };
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      SystemCallFilter = ["@system-service"];
      UMask = "0077";
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/bitwarden_rs"];
      ProtectProc = "invisible";
      ProtectClock = true;
      ProcSubset = "pid";
      PrivateUsers = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
      LockPersonality = true;
      RestrictNamespaces = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
    };
  };
}
