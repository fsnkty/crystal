{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
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
  users.users.main = {
    uid = lib.mkForce 1001; # wsl issue
    packages = [
      inputs.wire.packages.x86_64-linux.wire-small
      pkgs.wget
      pkgs.nixpkgs-fmt
      pkgs.nixd
    ];
  };
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
