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
    inputs@{
      nixpkgs,
      wire,
      lanzaboote,
      wsl,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
        portal = {
          imports = [
            lanzaboote.nixosModules.lanzaboote
          ];
        };
        library = { };
      };
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          wire.packages.x86_64-linux.wire-small
          pkgs.nixpkgs-fmt
          pkgs.deadnix
          pkgs.statix
        ];
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
