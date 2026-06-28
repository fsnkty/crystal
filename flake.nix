{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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
      nixosConfigurations = lib.genAttrs listHosts (
        name:
        lib.nixosSystem {
          modules = listNixRecursive [ ./modules ] ++ [
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
          pkgs.nixpkgs-fmt
          pkgs.deadnix
          pkgs.statix
          pkgs.nixd
        ];
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
