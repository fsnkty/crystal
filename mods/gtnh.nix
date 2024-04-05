{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.server.gtnh;
  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > ${config.systemd.sockets.gtnh.socketConfig.ListenFIFO}

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';
in
{
  options.server.gtnh = {
    enable = lib.mkEnableOption "enable service";
    dataDir = lib.mkOption { type = lib.types.path; };
  };
  config = lib.mkIf cfg.enable {
    users = {
      users.gtnh = {
        home = cfg.dataDir;
        createHome = true;
        isSystemUser = true;
        group = "gtnh";
      };
      groups.gtnh = { };
    };
    systemd = {
      sockets.gtnh = {
        bindsTo = [ "gtnh.service" ];
        socketConfig = {
          ListenFIFO = "/run/gtnh.stdin";
          SocketMode = "0660";
          SocketUser = "gtnh";
          SocketGroup = "gtnh";
          RemoveOnStop = true;
          FlushPending = true;
        };
      };
      services.gtnh = {
        wantedBy = [ "multi-user.target" ];
        requires = [ "gtnh.socket" ];
        after = [ "network.target" "gtnh.socket" ];
        serviceConfig = {
          ExecStart = "${
              lib.getExe pkgs.jre_headless
            } -Xms6G -Xmx6G -Dfml.readTimeout=180 @java21args.txt -jar lwjgl3ify-forgePatches.jar nogui";
          ExecStop = "${stopScript} $MAINPID";
          Restart = "always";
          User = "gtnh";
          WorkingDirectory = cfg.dataDir;
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
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          UMask = "0077";
        };
      };
    };
  };
}
