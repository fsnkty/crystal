{
  config,
  _lib,
  lib,
  ...
}:
{
  options._system =
    let
      inherit (_lib) mkEnable;
      inherit (lib) mkOption types;
    in
    {
      timeZone.NZ = mkEnable;
      setHostKey = mkEnable;
      wired = {
        enable = mkEnable;
        ip = mkOption { type = types.str; };
        name = mkOption { type = types.str; };
      };
    };
  config =
    let
      inherit (lib) mkIf mkMerge;
      inherit (config._system) timeZone setHostKey wired;
    in
    mkMerge [
      (mkIf timeZone.NZ {
        time.timeZone = "NZ";
        i18n.defaultLocale = "en_NZ.UTF-8";
      })
      (mkIf setHostKey {
        services.openssh.hostKeys = [
          {
            comment = "${config.networking.hostName} host";
            path = "/etc/ssh/${config.networking.hostName}_ed25519_key";
            type = "ed25519";
          }
        ];
      })
      (mkIf wired.enable {
        networking = {
          enableIPv6 = false;
          useDHCP = false;
        };
        systemd.network = {
          enable = true;
          networks.${wired.name} = {
            enable = true;
            inherit (wired) name;
            networkConfig = {
              DHCP = "no";
              DNSSEC = "yes";
              DNSOverTLS = "yes";
              DNS = [
                "1.1.1.1"
                "1.1.0.0"
              ];
            };
            address = [ "${wired.ip}/24" ];
            routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
          };
        };
      })
    ];
}
