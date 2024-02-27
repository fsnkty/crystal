{ config, lib, nuke, ... }: {
  options.service.web.komga = {
    enable = lib.mkEnableOption "";
    port = nuke.mkDefaultInt 8097;
  };
  config = lib.mkIf config.service.web.komga.enable {
    services = {
      komga = {
        enable = true;
        port = config.service.web.komga.port;
        openFirewall = true;
      };
    };
    systemd.services.komga.serviceConfig = {
      RemoveIPC = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      SystemCallFilter = [ "@system-service" ];
      UMask = "0077";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/komga" "/tmp" ];
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
