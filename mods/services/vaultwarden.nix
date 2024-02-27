{ config, lib, nuke, ... }: {
  options.service.web.vaultwarden = {
    enable = nuke.mkEnable;
    port = nuke.mkDefaultInt 8092;
  };
  config = lib.mkIf config.service.web.vaultwarden.enable {
    age.secrets.vault_env = {
      file = ../../shhh/vault_env.age;
      owner = "vaultwarden";
    };
    services = {
      vaultwarden = {
        enable = true;
        config = let inherit (config.networking) domain;
        in {
          DOMAIN = "https://vault.${domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = config.service.web.vaultwarden.port;
          ROCKET_LOG = "critical";
          SMTP_HOST = "mail.${domain}";
          SMPT_PORT = 465;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = "vault@${domain}";
          SMTP_FROM_NAME = "vault.${domain} Vaultwarden server";
          SMTP_USERNAME = "vault@${domain}";
        };
        environmentFile = config.age.secrets.vault_env.path;
      };
    };
    systemd.services.vaultwarden.serviceConfig = {
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      SystemCallFilter = [ "@system-service" ];
      UMask = "0077";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/bitwarden_rs" ];
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
