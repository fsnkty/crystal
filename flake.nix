{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    snms.url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
    mountain.url = "github:nu-nu-ko/mountain-nix";
    wsl.url = "github:nix-community/NixOS-WSL";
    # awaiting pr's # git+file/path/?ref=branch
    qbit.url = "github:nu-nu-ko/nixpkgs?ref=init-nixos-qbittorrent";
    navi.url = "github:nu-nu-ko/nixpkgs?ref=nixos-navidrome-cleanup";
  };
  outputs = inputs: {
    nixosConfigurations =
      let
        inherit (inputs.nixpkgs) lib;
      in
      lib.genAttrs
        [
          "factory"
          "library"
          "portal"
        ]
        (
          name:
          lib.nixosSystem {
            modules =
              builtins.concatMap
                (
                  path: builtins.filter (lib.hasSuffix ".nix") (map toString (lib.filesystem.listFilesRecursive path))
                )
                [
                  ./libs
                  ./mods
                ]
              ++ [ ./hosts/${name}.nix ];
            specialArgs = {
              inherit inputs;
            };
          }
        );
  };
}
