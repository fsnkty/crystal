{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
    agenix = {
      type = "github";
      owner = "ryantm";
      repo = "agenix";
      inputs = {
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    snms = {
      type = "gitlab";
      owner = "simple-nixos-mailserver";
      repo = "nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mountain = {
      type = "github";
      owner = "nu-nu-ko";
      repo = "mountain-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      type = "github";
      owner = "nix-community";
      repo = "NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # awaiting pr's # git+file/path/?ref=branch
    qbit = {
      type = "github";
      owner = "nu-nu-ko";
      repo = "nixpkgs";
      ref = "init-nixos-qbittorrent";
    };
    navi = {
      type = "github";
      owner = "nu-nu-ko";
      repo = "nixpkgs";
      ref = "nixos-navidrome-cleanup";
    };
    vault = {
      type = "github";
      owner = "nu-nu-ko";
      repo = "nixpkgs";
      ref = "nixos-vaultwarden-hardening";
    };
    komga = {
      type = "github";
      owner = "nu-nu-ko";
      repo = "nixpkgs";
      ref = "nixos-komga-hardening";
    };
  };
  outputs = inputs: {
    nixosConfigurations =
      let
        inherit (inputs.nixpkgs) lib;
        importAllList =
          paths:
          builtins.concatMap (
            path: builtins.filter (lib.hasSuffix ".nix") (map toString (lib.filesystem.listFilesRecursive path))
          ) paths;
      in
      lib.genAttrs
        [
          "factory"
          "library"
          "portal"
        ]
        (
          name:
          lib.nixosSystem {
            modules =
              importAllList [
                ./libs
                ./mods
              ]
              ++ [ ./hosts/${name}.nix ];
            specialArgs = {
              inherit inputs;
            };
          }
        );
  };
}
