{
  lib,
  nuke,
  config,
  ...
}:
{
  options.misc.wired = 
    let
      inherit (nuke) mkEnable mkStr;
    in
    {
      enable = mkEnable;
      ip = mkStr;
      card = mkStr;
    };
  config = 
    let
      inherit (lib) mkIf;
      cfg = config.misc.wired;
    in
    {
      networking = mkIf cfg.enable {
        enableIPv6 = false;
        useDHCP = false;
      };
      systemd.network = mkIf cfg.enable {
        enable = true;
        networks.${cfg.card} = {
          enable = true;
          name = cfg.card;
          networkConfig = {
            DHCP = "no";
            DNSSEC = "yes";
            DNSOverTLS = "yes";
            DNS = [
              "1.1.1.1"
              "1.1.0.0"
            ];
          };
          address = [ "${cfg.ip}/24" ];
          routes = [ {routeConfig.Gateway = "192.168.0.1"; } ];
        };
      };
    };
}
