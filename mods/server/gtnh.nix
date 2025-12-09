{ config, lib, pkgs, ... }:
let
  cfg = config.server.gtnh;
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) str path;
in
{
  options.server.gtnh = {
    enable = mkEnableOption "";
    user = mkOption {
        type = str;
        default = "gtnh";
    };
    group = mkOption {
        type = str;
        default = "gtnh";
    };
    dataDir = mkOption {
        type = path;
        default = "/var/lib/gtnh";
    };
    openFirewall = mkEnableOption "";
  };
  config = mkIf cfg.enable {
    systemd.services.gtnh = {
      wants = [ "network-online.target" ];
      after = [
        "local-fs.target"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        type = "simple";
        User = "gtnh";
        Group = "gtnh";
        ExecStart = "${lib.getExe pkgs.jre} -Xms6G -Xmx6G -Dfml.readTimeout=180 @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui";
        Restart = "always";
        WorkingDirectory = cfg.dataDir;

        # Hardening https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/games/minecraft-server.nix#L236
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
    users = {
      users = mkIf (cfg.user == "gtnh") {
        gtnh = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
      groups = mkIf (cfg.group == "gtnh") { gtnh = { }; };
    };
    networking.firewall = mkIf cfg.openFirewall ({
        allowedUDPPorts = [ 25565 ];
        allowedTCPPorts = [ 25565 ];
    });
  };
}
