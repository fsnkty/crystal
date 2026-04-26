{ ... }:
{
  # wsl
  wsl = {
    enable = true;
    defaultUser = "main";
    wslConf.user.default = "fsnkty";
    useWindowsDriver = true;
  };

  vscode.remote.setup = true;
  system = {
    lockdown = true;
    cleanup = true;
    nix = true;
    nz = true;
  };
  shell = {
    setup = true;
    prompt = "'%F{red}%m%f %~ %# '";
  };

  users = {
    mutableUsers = false;
    users.main = {
      name = "fsnkty";
      hashedPasswordFile = "/keys/user";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      uid = 1000;
    };
  };

  networking.hostName = "factory";

  # ssh
  programs.ssh.extraConfig = "
    Host *
      IdentityFile = ~/.ssh/factory
    Host library
      HostName = 119.224.63.166
      User = fsnkty
    Host portal
      HostName 192.168.0.121
      User fsnkty
    Host github.com
  ";
  # github
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      user = {
        name = "fsnkty";
        email = "fsnkty@pm.me";
        signingkey = "/home/fsnkty/.ssh/factory.pub";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };
  system.stateVersion = "24.11";
}
