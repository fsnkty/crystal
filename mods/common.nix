{ config, inputs, pkgs, lib, ... }:
let
  cfg = config.common;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.common = {
    cleanup = mkEnableOption "remove some default stuff";
    nix = mkEnableOption "sane nix defaults";
  };
  config = mkMerge [
    (mkIf cfg.cleanup {
      environment.defaultPackages = [ ];
      programs = {
        nano.enable = false;
        command-not-found.enable = false;
        bash.completion.enable = false;
      };
      xdg.sounds.enable = false;
      documentation = {
        enable = false;
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
      };
      boot.enableContainers = false;
    })
    (mkIf cfg.nix {
      system.rebuild.enableNg = true;
      nixpkgs = {
        hostPlatform = "x86_64-linux";
        config.allowUnfree = true;
      };
      nix = {
        package = pkgs.nixVersions.latest;
        settings = {
          allowed-users = [ "@wheel" ];
          experimental-features = [ "no-url-literals" "nix-command" "flakes" ];
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
        registry.nixpkgs.flake = inputs.nixpkgs;
        nixPath = [ "nixpkgs=flake:nixpkgs" ];
      };
      environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
    })
  ];
}
