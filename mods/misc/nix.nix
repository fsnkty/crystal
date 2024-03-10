{
  inputs,
  pkgs,
  lib,
  nuke,
  config,
  ...
}:
{
  options.misc.nix = {
    config = nuke.mkEnable;
    nh = nuke.mkEnable;
    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/storage/Repos/crystal";
    };
  };
  config =
    let
      inherit (lib) mkIf optionals;
      inherit (inputs) nixpkgs;
      cfg = config.misc.nix;
    in
    mkIf cfg.config {
      nix = {
        settings = {
          experimental-features = [
            "auto-allocate-uids"
            "no-url-literals"
            "nix-command"
            "flakes"
          ];
          auto-allocate-uids = true;
          auto-optimise-store = true;
          allowed-users = [ "@wheel" ];
          use-xdg-base-directories = true;
          nix-path = [ "nixpkgs=flake:nixpkgs" ];
        };
        optimise.automatic = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
        nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
        registry.nixpkgs.flake = nixpkgs;
        channel.enable = false;
      };
      nixpkgs = {
        hostPlatform = "x86_64-linux";
        config.allowUnfree = true;
      };
      environment = {
        etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
        sessionVariables.FLAKE = cfg.flakePath;
      };
      users.users.main.packages = optionals (cfg.nh) [ pkgs.nh ];
    };
}
