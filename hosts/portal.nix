{ inputs, config, ... }:
let
  inherit (config.users.users.main) name;
  inherit (inputs.wsl.nixosModules) wsl;
in
{
  ### wsl int
  imports = [ wsl ];
  wsl = {
    enable = true;
    defaultUser = name;
    wslConf.user.default = name;
    useWindowsDriver = true;
    usbup.eanble = true;
    startMenuLaucher = true;
  };
  
  misc = {
    nix = {
      config = true;
      flakePath = "home/${name}/crystal";
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
  networking.hostname = "portal";

  ### dont be silly
  system.stateVersion = "23.11";
}
