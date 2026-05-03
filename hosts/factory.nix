{ ... }:
{
  system = {
    cleanup = true;
    nix = true;
    nz = true;
  };
  users = {
    mainSetup = true;
    disableRoot = true;
    shell = {
      setup = true;
      prompt = "'%F{red}%m%f %~ %# '";
    };
    git.setup = true;
  };

  wsl = {
    enable = true;
    defaultUser = "main";
    wslConf = {
      user.default = "fsnkty";
      network.generateHosts = false; # might break port forwarding from wsl to windows, but it also breaks `networking.hosts`
      # the above should get a real fix, e.g.. merging the two properly.
    };
    useWindowsDriver = true;
  };
  vscode.remote.setup = true;

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
