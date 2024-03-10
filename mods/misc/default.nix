{
  pkgs,
  lib,
  nuke,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.agenix.nixosModules.default ];
  options.misc =
    let
      inherit (nuke) mkEnable;
    in
    {
      secrets = mkEnable;
      cleanDefaults = mkEnable;
      nztz = mkEnable;
    };
  config =
    let
      inherit (lib) mkIf;
      inherit (config.misc) secrets cleanDefaults nztz;
    in
    {
      ### secrets setup
      environment.systemPackages = mkIf secrets [ inputs.agenix.packages.${pkgs.system}.default ];
      age.identityPaths = mkIf secrets [ "/home/${config.users.users.main.name}/.ssh/id_ed25519" ];
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
      ### timezone
      time.timeZone = mkIf nztz "NZ";
      i18n.defaultLocale = mkIf nztz "en_NZ.UTF-8";
    };
}
