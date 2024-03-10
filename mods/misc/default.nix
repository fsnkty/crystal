{
  pkgs,
  lib,
  nuke,
  config,
  inputs,
  ...
}:
let
  inherit (nuke) mkEnable;
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.types)
    listOf
    package
    str
    bool
    ;
in
{
  imports = [ inputs.agenix.nixosModules.default ];
  options.misc = {
    users = {
      noRoot = mkEnable;
      main = {
        enable = mkOption {
          type = bool;
          default = true;
        };
        name = mkOption {
          type = str;
          default = "nuko";
        };
        packages = mkOption { type = listOf package; };
        keys = mkOption { type = listOf str; };
      };
    };
    secrets = mkEnable;
    cleanDefaults = mkEnable;
  };
  config =
    let
      inherit (config.misc) secrets cleanDefaults users;
      inherit (users) noRoot main;
    in
    {
      ### secrets setup
      environment.systemPackages = mkIf secrets [ inputs.agenix.packages.${pkgs.system}.default ];
      age.identityPaths = mkIf secrets [ "/home/${main.name}/.ssh/id_ed25519" ];

      age.secrets.user = mkIf main.enable {
        file = ../../shhh/user.age;
        owner = main.name;
      };
      users = {
        mutableUsers = !main.enable;
        users = {
          ### disableRoot
          root = mkIf noRoot {
            hashedPassword = "!";
            shell = pkgs.shadow;
            home = mkForce "/home/root"; # for sudo.
          };
          ### configure main user
          main = mkIf main.enable {
            uid = 1000;
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPasswordFile = config.age.secrets.user.path;
            inherit (main) name packages;
            openssh.authorizedKeys.keys = main.keys;
          };
        };
      };

      ### clean
      programs = mkIf cleanDefaults {
        nano.enable = false;
        command-not-found.enable = false;
      };
      environment.defaultPackages = mkIf cleanDefaults [ ];
      documentation = mkIf cleanDefaults {
        enable = false;
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
      };
      boot.enableContainers = mkIf cleanDefaults false;
    };
}
