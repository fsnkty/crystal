{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wsl.url = "github:nix-community/NixOS-WSL";
  };
  outputs = inputs: {
    nixosConfigurations =
      let
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
      # list of hostnames with an entry in /hosts/
      lib.genAttrs listHosts (
        name:
        lib.nixosSystem {
          # import all modules & its respective /hosts/ file
          modules = listNixRecursive [ ./mods ] ++ [ ./hosts/${name}.nix ];
          specialArgs = { inherit inputs; };
        }
      );
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
  };
}
