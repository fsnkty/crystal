{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];
  options.misc.ageSetup = lib.mkEnableOption "";
  config = lib.mkIf config.misc.ageSetup {
    environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];
    age.identityPaths = ["/home/${config.users.users.main.name}/.ssh/id_ed25519"];
  };
}
