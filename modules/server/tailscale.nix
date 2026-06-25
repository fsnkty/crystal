{ config, lib, ... }:
let
  cfg = config.crystal.server.networking.tailscale;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.crystal.server.networking.tailscale = {
    enable = mkEnableOption "";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      # 1. Enable the service and the firewall
      services.tailscale = {
        enable = true;
        authKeyFile = "/keys/tailscale";
      };
      networking = {
        nftables.enable = true;
        firewall = {
          enable = true;
          checkReversePath = "loose";
          trustedInterfaces = [ config.services.tailscale.interfaceName ];
          allowedUDPPorts = [ config.services.tailscale.port ];
        };
      };

      # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
      # This avoids the "iptables-compat" translation layer issues.
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];

      # 3. Optimization: Prevent systemd from waiting for network online
      # (Optional but recommended for faster boot with VPNs)
      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
    })
  ];
}
