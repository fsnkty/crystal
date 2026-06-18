{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.desktop.kde;
in
{
  options.crystal.desktop.kde = {
    enable = lib.mkEnableOption "";
  };
  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.plasma6 = {
        enable = true;
        # remove qt5 compat, hopefully wont need to enable this :)
        enableQt5Integration = false;
      };
      displayManager.plasma-login-manager.enable = true;
      # I dont need a screen reader
      orca.enable = lib.mkForce false;
    };
    environment.plasma6.excludePackages = builtins.attrValues {
      inherit (pkgs.kdePackages)
        aurorae # theme?
        plasma-browser-integration # maybe useful
        plasma-workspace-wallpapers # what
        konsole # alacritty instead
        #ark # gui 7zip? maybe useful ig
        elisa # music player
        #gwenview # photo viewer
        okular # document viewer
        kate # text editor
        ktexteditor # kate dep
        khelpcenter # obv
        #dolphin # file manager
        baloo-widgets # dolphin dep?
        dolphin-plugins # dolphin dep.
        #spectacle # screenshots
        #ffmpegthumbs # makes thumbnails of videos, prob just a dolphin dep
        krdp # rdp server
        ;
    };
    systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
    security.pam.services.plasmalogin-autologin.rules.auth = {
      systemd_loadkey = {
        order = 0;
        control = "optional";
        modulePath = "${pkgs.systemd}/lib/security/pam_systemd_loadkey.so";
      };
      plasmalogin = {
        order = 1;
        control = "include";
        modulePath = "plasmalogin";
      };
    };
  };
}
