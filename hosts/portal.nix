{ inputs, ... }:
{
  ### wsl int
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = "nuko";
    wslConf.user.default = "nuko";
    useWindowsDriver = true;
    usbip.enable = true;
    startMenuLaunchers = true;
  };

  misc = {
    nix = {
      config = true;
      flakePath = "/home/nuko/crystal";
      nh = true;
    };
    secrets = true;
    cleanDefaults = true;
    nztz = true;
  };
  user = {
    noRoot = true;
    main = {
      enable = true;
      shell.setup = true;
    };
  };
  program = {
    htop = true;
    neovim = true;
    git = true;
  };

  security.sudo.execWheelOnly = true;
  networking.hostName = "portal";

  ### dont be silly
  system.stateVersion = "23.11";
}
