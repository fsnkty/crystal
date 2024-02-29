{
  pkgs,
  inputs,
  config,
  ...
}:
{
  misc = {
    nix = {
      config = true;
      flakePath = "home/${config.users.users.main.name}/crystal";
      nh = true;
    };
    shell.enable = true;
    ageSetup = true;
    cleanDefaults = true;
    disableRoot = true;
  };
  program = {
    htop = true;
    neovim = true;
    git = true;
  };
  ### misc 
  time.timeZone = "NZ";
  i18n.defaultLocale = "en_NZ.UTF-8";
  security.sudo.execWheelOnly = true;
  ### user setup
  age.secrets.user = {
    file = ../shhh/user.age;
    owner = config.users.users.main.name;
  };
  users = {
    mutableUsers = false;
    users.main = {
      name = "nuko";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.age.secrets.users.path;
      packages = builtins.attrValues { inherit (pkgs) wget eza yazi; };
    };
  };
  ### wsl int
  networking.hostname = "portal";
  imports = [ inputs.wsl.nixosModules.wsl ];
  wsl = {
    enable = true;
    defaultUser = config.users.users.main.name;
    wslConf.user.default = config.users.users.main.name;
    useWindowsDriver = true;
    usbup.eanble = true;
    startMenuLaucher = true;
  };
  ### dont be silly
  system.stateVersion = "23.11";
}
