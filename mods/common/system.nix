{ config, inputs, pkgs, lib, ... }:
let
  cfg = config.system;
  inherit (lib) mkMerge mkIf mkEnableOption;
in
{
  options.system = {
    lockdown = mkEnableOption "close various potential security flaws";
    cleanup = mkEnableOption "remove some default stuff";
    nix = mkEnableOption "sane nix defaults";
    nz = mkEnableOption "all settings related to timezone/location being NZ";
  };
  config = mkMerge [
    (mkIf cfg.lockdown {
      users.users.root = {
        hashedPassword = lib.mkDefault "!"; # invalid hash will never resolve
        shell = lib.mkForce pkgs.shadow; # unuseable shell 
      };
    })
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
          trusted-users = [ "@wheel" ];
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
    (mkIf cfg.nz {
      time.timeZone = "Pacific/Auckland";
      i18n = {
        defaultLocale = "en_GB.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_NZ.UTF-8";
          LC_IDENTIFICATION = "en_NZ.UTF-8";
          LC_MEASUREMENT = "en_NZ.UTF-8";
          LC_MONETARY = "en_NZ.UTF-8";
          LC_NAME = "en_NZ.UTF-8";
          LC_NUMERIC = "en_NZ.UTF-8";
          LC_PAPER = "en_NZ.UTF-8";
          LC_TELEPHONE = "en_NZ.UTF-8";
          LC_TIME = "en_NZ.UTF-8";
        };
      };
    })
  ];
}
