{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wsl.url = "github:nix-community/NixOS-WSL";
    qbit.url = "github:fsnkty/nixpkgs/?ref=init-nixos-qbittorrent";
  };
  outputs = inputs: {
    nixosConfigurations =
      let
        inherit (inputs.nixpkgs) lib;
        importAllList = paths:
          builtins.concatMap
            (path:
              builtins.filter (lib.hasSuffix ".nix")
                (map toString (lib.filesystem.listFilesRecursive path)))
            paths;
      in
      # list of hostnames with an entry in /hosts/
      lib.genAttrs [ "factory" "library" "t460s" ] (name:
        lib.nixosSystem {
          # importing all modules & its respective /hosts/ file
          modules = importAllList [ ./mods ] ++ [ ./hosts/${name}.nix ];
          specialArgs = { inherit inputs; };
        });
  };
}
