{ inputs, pkgs, ... }: {
  system.stateVersion = "24.11";

  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = "fsnkty";
    wslConf.user.default = "fsnkty";
    useWindowsDriver = true;
  };

  networking.hostName = "factory";

  common = {
    cleanup = true;
    nix = true;
    nz = true;
  };

  users = {
    mutableUsers = false;
    users.main = {
      name = "fsnkty";
      hashedPasswordFile = "/keys/user";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  # wsl vscode server
  environment.systemPackages = [ pkgs.wget pkgs.nixpkgs-fmt ];
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # github
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      user = {
        name = "fsnkty";
        email = "fsnkty@pm.me";
        signingkey = "/home/fsnkty/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };
}
