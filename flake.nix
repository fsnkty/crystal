{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    # awaiting pr's | git+file/path/?ref=branch
    qbit.url = "github:nu-nu-ko/nixpkgs/?ref=init-nixos-qbittorrent";
    vault.url = "github:nu-nu-ko/nixpkgs/?ref=nixos-vaultwarden-hardening";
  };
  outputs =
    inputs:
    let
      inherit (builtins) concatMap filter;
      inherit (inputs.nixpkgs) lib;
      inherit (lib) genAttrs hasSuffix filesystem;
      genHosts =
        hosts:
        genAttrs hosts (
          name:
          lib.nixosSystem {
            modules =
              concatMap (x: filter (hasSuffix ".nix") (map toString (filesystem.listFilesRecursive x))) [
                ./libs
                ./mods
              ]
              ++ [ ./hosts/${name}.nix ];
            specialArgs = {
              inherit inputs;
            };
          }
        );
    in
    {
      nixosConfigurations = genHosts [
        "factory"
        "library"
      ];
    };
}
