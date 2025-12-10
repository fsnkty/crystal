{ inputs, pkgs, ... }: {
  # wsl
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = "main";
    wslConf.user.default = "fsnkty";
    useWindowsDriver = true;
  };
  # vscode server
  environment.systemPackages = [ pkgs.wget pkgs.nixpkgs-fmt ];
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
  };

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
    Host library
      HostName = 119.224.63.166
      User = fsnkty
      IdentityFile = /home/fsnkty/.ssh/factory
    Host github.com
      IdentityFile = /home/fsnkty/.ssh/factory
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
