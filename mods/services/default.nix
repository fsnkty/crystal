{ config, lib, nuke, ... }:
let
  inherit (lib) mkIf;
  inherit (config.service) fail2ban postgresql openssh;
in {
  options.service = {
    fail2ban = nuke.mkEnable;
    postgresql = nuke.mkEnable;
    openssh = nuke.mkEnable;
  };
  config.services = {
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
      knownHosts = {
        library = {
          extraHostNames = [ "tea.shimeji.cafe" "192.168.0.3" "119.224.63.166" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+1CxNCNvstjiRJFgJHVgqb/Mm1MJZOSoahwzgGXHMH";
        };
        factory = {
          extraHostNames = [ "192.168.0.4" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID93BZ8me5fD4jOFGokfO7o+sFMhh7FOBb2q7kMg4qN1";
        };
        "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
  };
}
