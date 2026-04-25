# generic systemd service setup for a non-declaritive MC server
let
  name = "gtnh";
in
{ config, lib, pkgs, ... }:
let
  cfg = config.server.${name};
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) str path int bool;
in
{
  options.server.${name} = {
    enable = mkEnableOption "";
    user = mkOption {
      type = str;
      default = "${name}";
    };
    group = mkOption {
      type = str;
      default = "${name}";
    };
    dataDir = mkOption {
      type = path;
      default = "/var/lib/${name}";
    };
    jvmPackage = lib.mkPackageOption pkgs "jvm" {
      default = "jre_minimal";
    };
    jvmOpts = lib.mkOption {
      type = lib.types.separatedString " ";
      default = "-Xmx2048M -Xms2048M";
    };
    openFirewall = mkOption {
      type = bool;
      default = false;
    };
    serverPort = mkOption {
      type = int;
      default = 25565;
    };
  };
  config = mkIf cfg.enable {
    systemd.services.${name} = {
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${lib.getExe cfg.jvmPackage} ${cfg.jvmOpts} nogui";
        WorkingDirectory = cfg.dataDir;

        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
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
    networking.firewall = lib.mkIf cfg.openFirewall (
      {
        allowedUDPPorts = [ cfg.serverPort ];
        allowedTCPPorts = [ cfg.serverPort ];
      }
    );
    users = {
      groups = mkIf (cfg.group == "${name}") { ${name} = { }; };
      users = mkIf (cfg.user == "${name}") {
        ${name} = {
          inherit (cfg) group;
          isSystemUser = true;
          home = cfg.dataDir;
          createHome = true;
        };
      };
    };
  };
}
