{
  pkgs,
  ...
}:
{
  crystal = {
    system = {
      cleanup = true;
      nix.setup = true;
      timezone.nz = true;
    };
    users = {
      main = {
        setup = true;
        shell = {
          setup = true;
          prompt = "'%F{red}%m%f %~ %# '";
        };
        git.setup = true;
      };
      root.disable = true;
    };
  };

  # vscode remote setup
  users.users.main.packages = [
    pkgs.wget
    pkgs.nixd
  ];
  programs.nix-ld.enable = true;

  wsl = {
    enable = true;
    defaultUser = "fsnkty";
    wslConf = {
      user.default = "fsnkty";
      network.generateHosts = false;
    };
  };

  networking.hosts = {
    "119.224.63.166" = [ "library" ];
    "192.168.0.121" = [ "portal" ];
  };

  # ssh
  programs.ssh.extraConfig = "
    Host *
      IdentityFile = ~/.ssh/factory
  ";
  system.stateVersion = "24.11";
}
