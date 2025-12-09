{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wsl.url = "github:nix-community/NixOS-WSL";
    jellyfinhardening.url = "github:jpds/nixpkgs/?ref=jellyfin-more-hardening";
  };
  outputs = inputs: {
    nixosConfigurations =
      let
        inherit (inputs.nixpkgs) lib;
        listNixRecursive = path:
          builtins.concatMap
            (p:
              builtins.filter (lib.hasSuffix ".nix")
                (map toString (lib.filesystem.listFilesRecursive p)))
            path;
        listHosts = builtins.map
          (host:
            (lib.removeSuffix ".nix" host))
          (builtins.attrNames (builtins.readDir ./hosts));
      in
      # list of hostnames with an entry in /hosts/
      lib.genAttrs listHosts (name:
        lib.nixosSystem {
          # import all modules & its respective /hosts/ file
          modules = listNixRecursive [ ./mods ] ++ [ ./hosts/${name}.nix ];
          specialArgs = { inherit inputs; };
        });
  };
}
