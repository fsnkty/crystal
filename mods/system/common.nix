{
  inputs,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  imports = [ inputs.agenix.nixosModules.default ];
  options._system =
    let
      inherit (lib) mkOption types;
      inherit (_lib) mkEnable;
    in
    {
      nix = {
        config = mkEnable;
        nh = mkEnable;
        flakePath = lib.mkOption {
          type = lib.types.str;
          default = "/storage/Repos/crystal";
        };
      };
      agenix.setup = mkEnable;
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
      inherit (lib) mkMerge mkIf optionals;
      inherit (config._system)
        nix
        agenix
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
          bash.enableCompletion = false;
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
      (mkIf agenix.setup {
        environment.systemPackages = [ inputs.agenix.packages.${pkgs.system}.default ];
        age.identityPaths = [ "/home/${config.users.users.main.name}/.ssh/id_ed25519" ];
      })
      (mkIf nix.config {
        environment = {
          etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
          sessionVariables.FLAKE = nix.flakePath;
        };
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
            allowed-users = [ "@wheel" ];
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
        users.users.main.packages = optionals nix.nh [ pkgs.nh ];
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
            enable = true;
            inherit (wired) name;
            networkConfig = {
              DHCP = "no";
              DNSSEC = "yes";
              DNSOverTLS = "yes";
              DNS = [
                "1.1.1.1"
                "1.1.0.0"
              ];
            };
            address = [ "${wired.ip}/24" ];
            routes = [ { routeConfig.Gateway = "192.168.0.1"; } ];
          };
        };
      })
    ];
}
