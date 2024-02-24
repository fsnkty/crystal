{ config, lib, ... }: {
  options.service.blocky = lib.mkEnableOption "";
  config = lib.mkIf config.service.blocky {
    services.blocky = {
      enable = true;
      settings = {
        connectIPVersion = "v4";
        prometheus = {
          enable = true;
          path = "/metrics";
        };
        upstreams.groups.default =
          [ "1.1.1.1" "1.0.0.1" "118.148.1.10" "118.148.1.20" ];
        blocking = {
          blackLists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
          };
          clientGroupsBlock = { default = [ "ads" ]; };
        };
        customDNS = { mapping = { "router.lan" = "192.168.0.1"; }; };
        ports = {
          dns = 52;
          http = 4000;
        };
      };
    };
  };
}
