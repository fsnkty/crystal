{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options.misc.nix = {
    config = lib.mkEnableOption "";
    flakePath = lib.mkOption {type = lib.types.str;};
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
        allowed-users = ["@wheel"]; # why would this not be default
        use-xdg-base-directories = true; # keep ~ clean.
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nixPath = ["nixpkgs=/etc/nix/inputs/nixpkgs"];
      registry.nixpkgs.flake = inputs.nixpkgs;
    };
    nixpkgs = {
      hostPlatform = "x86_64-linux";
      config.allowUnfree = true;
    };
    environment = {
      etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
      sessionVariables.FLAKE = config.misc.nix.flakePath;
    };
    documentation.enable = false;
    users.users.main.packages = lib.optionals (config.misc.nix.nh) [inputs.nh.packages.${pkgs.system}.default];
  };
}
