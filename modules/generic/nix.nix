{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.system.nix.setup = lib.mkEnableOption "Flake first & opionated nix defaults";
  config = lib.mkIf config.crystal.system.nix.setup {
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        allowed-users = [ "@wheel" ];
        trusted-users = [ "@wheel" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      # never used channels anyway
      channel.enable = false;
      #registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
    };
    environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
  };
}
