{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.local.misc.ageSetup = lib.mkEnableOption "";
  config = lib.mkIf config.local.misc.ageSetup {
    environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];
    age.identityPaths = ["/home/${config.users.users.main.name}/.ssh/id_ed25519"];
  };
}
