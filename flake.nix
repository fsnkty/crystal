{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # awaiting pr's | git+file/path/?ref=branch
    qbit.url = "github:fsnkty/nixpkgs/?ref=init-nixos-qbittorrent";
    vault.url = "github:fsnkty/nixpkgs/?ref=nixos-vaultwarden-hardening";
  };
  outputs = inputs: {
    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        specialArgs = {
          inherit inputs;
        };
      };
      defaults =
        { name, ... }:
        {
          imports =
            let
              inherit (inputs.nixpkgs.lib) hasSuffix filesystem;
            in
            builtins.concatMap
              (x: builtins.filter (hasSuffix ".nix") (map toString (filesystem.listFilesRecursive x)))
              [
                ./libs
                ./mods
              ]
            ++ [ ./hosts/${name}.nix ];
          deployment = {
            targetUser = "fsnkty";
            allowLocalDeployment = true;
          };
        };
      factory.deployment.targetHost = null;
      library.deployment.targetHost = "192.168.0.3";
    };
  };
}
