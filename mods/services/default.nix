{
  config,
  lib,
  nuke,
  ...
}:
{
  options.service = {
    fail2ban = nuke.mkEnable;
    postgresql = nuke.mkEnable;
    openssh = nuke.mkEnable;
  };
  config.services =
    let
      inherit (lib) mkIf;
      inherit (config.service) fail2ban postgresql openssh;
    in
    {
      ### fail2ban
      fail2ban = mkIf fail2ban {
        enable = true;
        bantime-increment = {
          enable = true;
          factor = "16";
        };
        jails = {
          dovecot.settings = {
            filter = "dovecot[mode=aggressive]";
            maxretry = 3;
          };
          nginx-botsearch.settings = {
            maxretry = 5;
            findtime = 30;
          };
        };
      };
      ### postgresql
      postgresql = mkIf postgresql { enable = true; };
      ### openssh
      openssh = mkIf openssh {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          LogLevel = "VERBOSE";
        };
      };
    };
}
