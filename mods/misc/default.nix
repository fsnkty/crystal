
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];
  options.misc = {
    ageSetup = lib.mkEnableOption "";
    disableRoot = lib.mkEnableOption "";
    cleanDefaults = lib.mkEnableOption "";
  };
  config = let
    inherit (lib) mkIf;
    inherit (config.misc) ageSetup disableRoot cleanDefaults;
  in {
    ### ageSetup
    environment.systemPackages = mkIf ageSetup [inputs.agenix.packages.${pkgs.system}.default];
    age.identityPaths = mkIf ageSetup ["/home/${config.users.users.main.name}/.ssh/id_ed25519"];
    ### disableRoot
    users.users.root = mkIf disableRoot {
      hashedPassword = "!";
      shell = pkgs.shadow;
      home = lib.mkForce "/home/root";# for sudo.
    };
    ### clean
    programs = mkIf cleanDefaults {
      nano.enable = false;
      command-not-found.enable = false;
    };
    environment.defaultPackages = mkIf cleanDefaults [];
    documentation = {
      # online pages are easier to navigate.
      enable = false;
      doc.enable = false;
      info.enable = false;
      man.enable = false;
      nixos.enable = false;
    };
    boot.enableContainers = false;
  };
}
