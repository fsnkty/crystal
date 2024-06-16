{
  inputs,
  config,
  _lib,
  lib,
  ...
}:
{
  options._system =
    let
      inherit (lib) mkOption types;
      inherit (_lib) mkEnable;
    in
    {
      nix.config = mkEnable;
      cleanup = mkEnable;
      timeZone.NZ = mkEnable;
      setHostKey = mkEnable;
      wired = {
        enable = mkEnable;
        ip = mkOption { type = types.str; };
        name = mkOption { type = types.str; };
      };
    };
  config =
    let
      inherit (lib) mkMerge mkIf;
      inherit (config._system)
        nix
        cleanup
        timeZone
        setHostKey
        wired
        ;
    in
    mkMerge [
      (mkIf cleanup {
        environment.defaultPackages = [ ];
        programs = {
          nano.enable = false;
          command-not-found.enable = false;
          bash.completion.enable = false;
        };
        xdg.sounds.enable = false;
        documentation = {
          enable = false;
          doc.enable = false;
          info.enable = false;
          nixos.enable = false;
        };
        boot.enableContainers = false;
      })
      (mkIf nix.config {
        security.sudo.wheelNeedsPassword = false; # colmena pain
        environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
        nix = {
          settings = {
            experimental-features = [
              "auto-allocate-uids"
              "no-url-literals"
              "nix-command"
              "flakes"
            ];
            auto-allocate-uids = true;
            auto-optimise-store = true;
            use-xdg-base-directories = true;
            trusted-users = [ "nuko" ];
            nix-path = [ "nixpkgs=flake:nixpkgs" ];
          };
          nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
          registry.nixpkgs.flake = inputs.nixpkgs;
          channel.enable = false;
          optimise.automatic = true;
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };
        nixpkgs = {
          hostPlatform = "x86_64-linux";
          config.allowUnfree = true;
        };
      })
      (mkIf timeZone.NZ {
        time.timeZone = "NZ";
        i18n.defaultLocale = "en_NZ.UTF-8";
      })
      (mkIf setHostKey {
        services.openssh.hostKeys = [
          {
            comment = "${config.networking.hostName} host";
            path = "/etc/ssh/${config.networking.hostName}_ed25519_key";
            type = "ed25519";
          }
        ];
      })
      (mkIf wired.enable {
        networking = {
          enableIPv6 = false;
          useDHCP = false;
        };
        systemd.network = {
          enable = true;
          networks.${wired.name} = {
            inherit (wired) enable name;
            networkConfig.DHCP = "no";
            address = [ "${wired.ip}/24" ];
            routes = [ { Gateway = "192.168.0.1"; } ];
          };
        };
      })
    ];
}
