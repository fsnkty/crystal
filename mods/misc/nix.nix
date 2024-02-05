{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  options.misc.nix = {
    config = lib.mkEnableOption "";
    flakePath = lib.mkOption { type = lib.types.str; };
    nh = lib.mkEnableOption "";
  };
  config = lib.mkIf config.misc.nix.config {
    nix = {
      settings = {
        experimental-features = [
          "auto-allocate-uids"
          "no-url-literals"
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        allowed-users = [ "@wheel" ];
        use-xdg-base-directories = true;
        nix-path = ["nixpkgs=flake:nixpkgs"];
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
      registry.nixpkgs.flake = inputs.nixpkgs;
      channel.enable = false;
    };
    nixpkgs = {
      hostPlatform = "x86_64-linux";
      config.allowUnfree = true;
    };
    environment = {
      etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
      sessionVariables.FLAKE = config.misc.nix.flakePath;
    };
    users.users.main.packages = lib.optionals (config.misc.nix.nh) [ pkgs.nh ];
  };
}
