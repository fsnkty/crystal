{
  lib,
  config,
  ...
}: {
  options.misc.cleanDefaults = lib.mkEnableOption "";
  config = lib.mkIf config.misc.cleanDefaults {
    programs = {
      nano.enable = lib.mkForce false;
      command-not-found.enable = lib.mkForce false;
    };
    environment = {
      defaultPackages = lib.mkForce [];
      noXlibs = lib.mkForce false; # borks hard, one day.
    };
    # online pages are easier to navigate.
    documentation = {
      enable = lib.mkForce false;
      doc.enable = lib.mkForce false;
      info.enable = lib.mkForce false;
      man.enable = lib.mkForce false;
      nixos.enable = lib.mkForce false;
    };
    boot.enableContainers = lib.mkForce false;
  };
}
