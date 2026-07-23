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

      # Force tailscaled to use nftables
      # This avoids the "iptables-compat" translation layer issues.
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
    })
  ];
}
