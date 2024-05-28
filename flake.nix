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
      inherit (inputs) nixpkgs;
      inherit (nixpkgs.lib) hasSuffix filesystem;
    in
    {
      colmena = {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
          specialArgs = {inherit inputs;};
        };
        defaults = {name, ...}: {
          imports = concatMap (x: filter (hasSuffix ".nix") (map toString (filesystem.listFilesRecursive x))) [
            ./libs
            ./mods
          ]
          ++ [ ./hosts/${name}.nix ];
        };
        factory.deployment = {
          allowLocalDeployment = true;
          targetHost = null;
        };
        library.deployment = {
          targetUser = "nuko";
          targetHost = "192.168.0.3";
        };
      };
    };
}
