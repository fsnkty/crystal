{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wire = {
      # deployment
      url = "github:forallsys/wire/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      # windows subsystem for linux
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      # secure boot systemd-boot
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      wire,
      wsl,
      lanzaboote,
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
      wire = wire.makeHive {
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
        factory = { };
        library = { };
        portal = { };
      };
      nixosConfigurations = lib.genAttrs listHosts (
        name:
        lib.nixosSystem {
          modules = listNixRecursive [ ./modules ] ++ [
            wire.nixosModules.default
            wsl.nixosModules.wsl
            lanzaboote.nixosModules.lanzaboote
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
          wire.packages.x86_64-linux.wire-small
          pkgs.nixpkgs-fmt
          pkgs.deadnix
          pkgs.statix
          pkgs.nh
        ];
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
