{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      # systemd-boot secure boot
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      # $HOME manager
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      inherit (inputs.nixpkgs) lib;
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
          pkgs.nh
        ];
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
