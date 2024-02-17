{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    snms.url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
    mountain.url = "github:nu-nu-ko/mountain-nix";
    # awaiting pr's # git+file/path/?ref=branch
    qbit.url = "git+file:/storage/repos/nixpkgs/?ref=init-nixos-qbittorrent";
    #qbit.url = "github:nu-nu-ko/nixpkgs?ref=init-nixos-qbittorrent";
    navi.url = "github:nu-nu-ko/nixpkgs?ref=nixos-navidrome-cleanup";
  };
  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      importAll = path:
        builtins.filter (lib.hasSuffix ".nix")
        (map toString (lib.filesystem.listFilesRecursive path));
    in {
      nixosConfigurations = lib.genAttrs [ "factory" "library" ] (name:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${name}.nix ] ++ importAll ./libs
            ++ importAll ./mods;
        });
    };
}
