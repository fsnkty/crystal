{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=317484b1ead87b9c1b8ac5261a8d2dd748a0492d";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    snms.url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
    mountain.url = "github:nu-nu-ko/mountain-nix";
    # awaiting pr's
    qbit.url = "github:nu-nu-ko/nixpkgs?ref=nixos/qbittorrent-init";
    jelly.url = "github:nu-nu-ko/nixpkgs?ref=nixos-jellyfin-dirs";
  };
  outputs = inputs: let
    inherit (inputs.nixpkgs.lib) hasSuffix filesystem genAttrs nixosSystem;
  in {
    nixosConfigurations = let
      importAll = path:
        builtins.filter (hasSuffix ".nix")
        (map toString (filesystem.listFilesRecursive path));
    in
      genAttrs [
        "factory"
        "library"
      ] (name:
        nixosSystem {
          specialArgs = {inherit inputs;};
          modules =
            [./hosts/${name}.nix]
            ++ importAll ./libs
            ++ importAll ./mods;
        });
  };
}
