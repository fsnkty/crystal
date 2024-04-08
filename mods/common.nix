{
  inputs,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  imports = [ inputs.agenix.nixosModules.default ];
  options._common =
    let
      inherit (_lib) mkEnable;
    in
    {
      nix = {
        config = mkEnable;
        nh = mkEnable;
        flakePath = lib.mkOption {
          type = lib.types.str;
          default = "/storage/Repos/crystal";
        };
      };
      agenix.setup = mkEnable;
      cleanup = mkEnable;
    };
  config =
    let
      inherit (lib) mkMerge mkIf optionals;
      inherit (config._common) nix agenix cleanup;
    in
    mkMerge [
      (mkIf agenix.setup {
        environment.systemPackages = [ inputs.agenix.packages.${pkgs.system}.default ];
        age.identityPaths = [ "/home/${config.users.users.main.name}/.ssh/id_ed25519" ];
      })
      (mkIf cleanup {
        environment.defaultPackages = [ ];
        programs = {
          nano.enable = false;
          command-not-found.enable = false;
          bash.enableCompletion = false;
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
      (mkIf nix.config {
        environment = {
          etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
          sessionVariables.FLAKE = nix.flakePath;
        };
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
            use-xdg-base-directories = true;
            allowed-users = [ "@wheel" ];
            nix-path = [ "nixpkgs=flake:nixpkgs" ];
          };
          nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
          registry.nixpkgs.flake = inputs.nixpkgs;
          channel.enable = false;
          optimise.automatic = true;
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };
        nixpkgs = {
          hostPlatform = "x86_64-linux";
          config.allowUnfree = true;
        };
        users.users.main.packages = optionals nix.nh [ pkgs.nh ];
      })
    ];
}
