{ config
, lib
, ...
}:
{
  options.crystal.programs.firefox = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.programs.firefox {
    programs.firefox = {
      enable = true;
      languagePacks = [ "en-US" "en-GB" ];
      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;

        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableMasterPasswordCreation = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSetDesktopBackground = true;
        DisablePocket = true;
        DisableTelemetry = true;

        DontCheckDefaultBrowser = true;
        HardwareAcceleration = true;
        OfferToSaveLogins = false;
        
        ExtensionSettings =
          let
            moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
          in
          {
            "*".installation_mode = "blocked";

            "uBlock0@raymondhill.net" = {
              install_url = moz "ublock-origin";
              installation_mode = "force_installed";
              updates_disabled = true;
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = moz "bitwarden-password-manager";
              installation_mode = "force_installed";
              updates_disabled = true;
            };
            "{25cddbee-458b-4e9f-984d-dbf35511f124}" = {
              install_url = moz "chatreplay";
              installation_mode = "force_installed";
              updates_disabled = true;
            };
            "sponsorBlocker@ajay.app" = {
              install_url = moz "sponsorblock";
              installation_mode = "force_installed";
              updates_disabled = true;
            };
          };
      };
    };
  };
}
