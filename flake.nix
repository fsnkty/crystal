{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wire = {
      url = "github:forallsys/wire/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      listNixRecursive =
        path:
        builtins.concatMap (
          p: builtins.filter (lib.hasSuffix ".nix") (map toString (lib.filesystem.listFilesRecursive p))
        ) path;
      listHosts = map (host: (lib.removeSuffix ".nix" host)) (
        builtins.attrNames (builtins.readDir ./hosts)
      );
    in
    {
      wire = inputs.wire.makeHive {
        inherit (self) nixosConfigurations;
        meta = {
          nixpkgs = import nixpkgs { localSystem = system; };
          specialArgs = { inherit inputs; };
        };
        defaults =
          { name, ... }:
          {
            deployment.target = {
              user = "fsnkty";
              hosts = name;
            };
          };
        library = { };
        portal = { };
        cafe = { };
      };
      nixosConfigurations = lib.genAttrs listHosts (
        name:
        lib.nixosSystem {
          modules = listNixRecursive [ ./modules ] ++ [
            inputs.wire.nixosModules.default
            inputs.lanzaboote.nixosModules.lanzaboote
            ./hosts/${name}.nix
            {
              nixpkgs.hostPlatform = system;
              networking.hostName = name;
            }
          ];
          specialArgs = { inherit inputs; };
        }
      );
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          inputs.wire.packages.x86_64-linux.wire-small
          pkgs.nixpkgs-fmt
          pkgs.deadnix
          pkgs.statix
          pkgs.nixd
        ];
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
