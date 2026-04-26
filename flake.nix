{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wire.url = "github:forallsys/wire/stable"; # deployment
    wsl.url = "github:nix-community/NixOS-WSL";
  };
  outputs = inputs @ {
    nixpkgs,
    wire,
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
      defaults = {name, ... }: {
        nixpkgs = {
          hostPlatform = system;
          config.allowUnfree = true;
        };
        imports = listNixRecursive [ ./mods ] ++ [ ./hosts/${name}.nix];
        deployment.target = {
          user = "fsnkty";
          hosts = "${name}";
        };
      };
      portal = { };
      factory = {
        imports = [wsl.nixosModules.wsl];
      };
      library = {
        deployment.allowLocalDeployment = false;
      };
    };
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = [
        wire.packages.${system}.wire-small # non -small requires aarch64 for some reason
      ];
    };
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
  };
}