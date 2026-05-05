{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wire = {
      # deployment
      url = "github:forallsys/wire/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      # /home/ management
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      # windows subsystem for linux
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      wire,
      hjem,
      wsl,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      listNixRecursive =
        path:
        builtins.concatMap (
          p: builtins.filter (lib.hasSuffix ".nix") (map toString (lib.filesystem.listFilesRecursive p))
        ) path;
      system = "x86_64-linux"; # I only have amd64 systems for now
    in
    {
      wire = wire.makeHive {
        meta = {
          nixpkgs = import nixpkgs { localSystem = system; };
          specialArgs = { inherit inputs; };
        };
        defaults =
          { name, ... }:
          {
            nixpkgs.hostPlatform = system;
            networking.hostName = "${name}";
            imports = listNixRecursive [ ./mods ] ++ [
              ./hosts/${name}.nix
              hjem.nixosModules.default
            ];
            deployment.target = {
              user = "fsnkty";
              hosts = "${name}";
            };
          };
        factory = {
          deployment.tags = [ "deployable" ];
          imports = [ wsl.nixosModules.wsl ];
        };
        portal = {
          deployment.tags = [ "deployable" ];
        };
        library = {
          deployment.tags = [ "deployable" ];
        };
        recovery = { };
      };
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = [
          wire.packages.${system}.wire-small # non -small requires aarch64 for some reason
        ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
