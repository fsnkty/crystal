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
    wslConf.user.default = "fsnkty";
    useWindowsDriver = true;
  };
  vscode.remote.setup = true;

  # ssh
  programs.ssh.extraConfig = "
    Host library
      IdentityFile = ~/.ssh/factory
      HostName = 119.224.63.166
    Host portal
      IdentityFile = ~/.ssh/factory
      HostName 192.168.0.121
    Host github.com
  ";
  system.stateVersion = "24.11";
}
