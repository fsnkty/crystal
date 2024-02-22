{ config, lib, ... }: {
  options.service.web.komga = lib.mkEnableOption "";
  config = lib.mkIf config.service.web.komga {
    services = {
      komga = {
        enable = true;
        port = 8097;
        openFirewall = true;
      };
      nginx.virtualHosts."komga.${config.service.web.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:8097";
      };
    };
    systemd.services.komga.serviceConfig = {
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      SystemCallFilter = ["@system-service"];
      UMask = "0077";
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/komga" "/tmp"];
      ProtectHome = true;
      PrivateTmp = true;
      ProtectProc = "invisible";
      ProtectClock = true;
      ProcSubset = "pid";
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
      LockPersonality = true;
      RestrictNamespaces = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
    };
  };
}
