{ inputs, pkgs, lib, ... }:
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
    cleanDefaults = true;
    nztz = true;
  };
  user.main.shell.setup = lib.mkForce true;
  users = {
    mutableUsers = false;
    users.main = {
      hashedPassword = "$y$j9T$9CtCHeGALxxXBPyMXMgey0$/JZcbnVI78ScTlGtn.P1BAnRGreo8WsXG1Yr4dj7JM2";
      uid = 1001;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      name = "nuko";
      packages = builtins.attrValues {
        inherit (pkgs)
          wget
          yazi
          ;
      };
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
