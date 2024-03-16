{
  # hate how inputs must be trivial but whatever
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";
    # extras.. 
    agenix.url = "github:ryantm/agenix";
    snms.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    wsl.url = "github:nix-community/NixOS-WSL";
    mountain.url = "github:nu-nu-ko/mountain-nix";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    # no need to keep so many nixpkgs inputs
    agenix.inputs = {
      nixpkgs.follows = "nixpkgs";
      darwin.follows = "";
      home-manager.follows = "";
    };
    wsl.inputs.nixpkgs.follows = "nixpkgs";
    snms.inputs.nixpkgs.follows = "nixpkgs";
    mountain.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    # awaiting pr's # git+file/path/?ref=branch
    qbit.url = "github:nu-nu-ko/nixpkgs/?ref=init-nixos-qbittorrent";
    navi.url = "github:nu-nu-ko/nixpkgs/?ref=nixos-navidrome-cleanup";
    vault.url = "github:nu-nu-ko/nixpkgs/?ref=nixos-vaultwarden-hardening";
  };
  outputs = inputs: {
    nixosConfigurations =
      let
        inherit (inputs.nixpkgs) lib;
        importAllList =
          paths:
          builtins.concatMap (
            path: builtins.filter (lib.hasSuffix ".nix") (map toString (lib.filesystem.listFilesRecursive path))
          ) paths;
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
              importAllList [
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
