{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    mapAttrs'
    nameValuePair
    flatten
    ;
  inherit (lib.types)
    str
    int
    bool
    path
    attrsOf
    submodule
    separatedString
    ;
  cfg = config.crystal.server.minecraft-servers;

  instanceOpts =
    { name, ... }:
    {
      options = {
        enable = mkEnableOption "Minecraft server instance";
        user = mkOption {
          type = str;
          default = name;
        };
        group = mkOption {
          type = str;
          default = name;
        };
        dataDir = mkOption {
          type = path;
          default = "/var/lib/${name}";
        };
        jvmPackage = mkPackageOption pkgs "jvm" { default = "jre_minimal"; };
        jvmOpts = mkOption {
          type = separatedString " ";
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
    };
in
{
  options.crystal.server.minecraft-servers = mkOption {
    type = attrsOf (submodule instanceOpts);
    default = { };
  };

  config = {
    systemd = {
      services = mapAttrs' (
        name: instance:
        nameValuePair "minecraft-${name}" (
          mkIf instance.enable {
            wantedBy = [ "multi-user.target" ];
            requires = [ "minecraft-${name}.socket" ];
            after = [
              "network.target"
              "minecraft-${name}.socket"
            ];
            serviceConfig = {
              ExecStart = "${lib.getExe instance.jvmPackage} ${instance.jvmOpts} nogui";
              ExecStop = "${pkgs.writeShellScript "${name}-stop" ''
                echo stop > ${config.systemd.sockets.${"minecraft-${name}"}.socketConfig.ListenFIFO}
                # Wait for the PID of the minecraft server to disappear before
                # returning, so systemd doesn't attempt to SIGKILL it.
                while kill -0 "$1" 2> /dev/null; do
                  sleep 1s
                done

              ''} $MAINPID";
              Restart = "on-failure"; # so stop and sysctl stop work.
              User = instance.user;
              Group = instance.group;
              WorkingDirectory = instance.dataDir;

              StandardInput = "socket";
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
          }
        )
      ) cfg;
      sockets = mapAttrs' (
        name: instance:
        nameValuePair "minecraft-${name}" (
          mkIf instance.enable {
            bindsTo = [ "minecraft-${name}.service" ];
            socketConfig = {
              ListenFIFO = "/run/minecraft-${name}.stdin";
              SocketMode = "0660";
              SockerUser = instance.user;
              SocketGroup = instance.group;
              RemoveOnStop = true;
              FlushPending = true;
            };
          }
        )
      ) cfg;
    };
    users = {
      users = mapAttrs' (
        name: instance:
        nameValuePair instance.user (
          mkIf instance.enable {
            inherit (instance) group;
            home = instance.dataDir;
            isSystemUser = true;
          }
        )
      ) cfg;
      groups = mapAttrs' (name: instance: nameValuePair instance.group (mkIf instance.enable { })) cfg;
    };

    networking.firewall.allowedTCPPorts = flatten (
      lib.mapAttrsToList (
        name: instance: lib.optional (instance.enable && instance.openFirewall) instance.serverPort
      ) cfg
    );
  };
}
