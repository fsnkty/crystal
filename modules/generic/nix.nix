{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.system.nix.setup = lib.mkEnableOption "Flake first nix config";
  config = lib.mkIf config.crystal.system.nix.setup {
    nixpkgs.config.allowUnfree = true;
    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      package = pkgs.nixVersions.latest;
      settings = {
        allowed-users = [ "@wheel" ];
        trusted-users = [ "@wheel" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        nix-path = [ "nixpkgs=flake:nixpkgs" ];
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      channel.enable = false;
    };
    environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
  };
}
