{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "";
      };
    };
    snms.url = "gitlab:/simple-nixos-mailserver/nixos-mailserver";
    conduit.url = "gitlab:famedly/conduit?ref=next";
    
    mountain.url = "github:nu-nu-ko/mountain-nix";
    # awaiting pr's
    rwp.url = "github:nu-nu-ko/nixpkgs?ref=init-rwpspread";
    jelly.url = "github:nu-nu-ko/nixpkgs?ref=nixos-jellyfin-dirs";
    #qbit.url = "github:nu-nu-ko/nixpkgs?ref=init-nixos-qbittorrent";
    qbit.url = "git+file:/storage/repos/nixpkgs?ref=init-nixos-qbittorrent";
    #jelly.url = "git+file:/storage/repos/nixpkgs?ref=nixos-jellyfin-dirs";
  };
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs.lib.filesystem) listFilesRecursive;
      inherit (inputs.nixpkgs.lib) hasSuffix genAttrs nixosSystem;
      inherit (builtins) filter;
    in
    {
      nixosConfigurations =
        let
          importAll = path: filter (hasSuffix ".nix") (map toString (listFilesRecursive path));
        in
        genAttrs
          [
            "factory"
            "library"
          ]
          (
            name:
            nixosSystem {
              specialArgs = {
                inherit inputs;
              };
              modules = [ ./hosts/${name}.nix ] ++ importAll ./libs ++ importAll ./mods;
            }
          );
    };
}
