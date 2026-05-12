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
      wsl,
      ...
    }:
    {
      wire = wire.makeHive {
        meta = {
          nixpkgs = import nixpkgs { localSystem = "x86_64-linux"; };
          specialArgs = { inherit inputs; };
        };
        defaults =
          { name, ... }:
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            networking.hostName = "${name}";
            imports =
              builtins.concatMap (
                p:
                builtins.filter (nixpkgs.lib.hasSuffix ".nix") (
                  map toString (nixpkgs.lib.filesystem.listFilesRecursive p)
                )
              ) [ ./mods ]
              ++ [ ./hosts/${name}.nix ];
            deployment.target = {
              user = "fsnkty";
              hosts = "${name}";
            };
          };
        factory = {
          imports = [
            wsl.nixosModules.wsl
          ];
        };
        portal = { };
        library = { };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
