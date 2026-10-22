{ config
, lib
, pkgs
, utils
, ...
}:
let
  cfg = config.crystal.desktop.kde;
  inherit (pkgs) kdePackages;
  inherit (lib) types;
in
{
  # assumes..
  # 1. KDE/QT ONLY / first.
  # 2. plasma-login-manager
  # 3. zero desire to non-declaritively use any sort of theme, plasmoid, etc
  # 4. little to no desire to non-declaritively configure KDE
  # e.g.. theme etc, "little to no" since some config, e.g.. managing bluetooth devices etc is fairly fundamentally imperitive
  # no care for qt5 :shrug:
  options.crystal.desktop.kde = {
    enable = lib.mkEnableOption "";
    excludePackages = lib.mkOption {
      description = "List of kde related packages to exclude, ANYTHING can be excluded, so use common sense, see the module source for more info";
      type = types.listOf types.package;
      default = [ ];
    };
    kwallet = {
      enable = lib.mkEnableOption "";
      luks = lib.mkEnableOption "";
      manager = lib.mkEnableOption "";
    };
    drkonqi = lib.mkEnableOption "";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      qt = {
        enable = true;
        style = "breeze";
        platformTheme = "kde";
      };
      environment = {
        laminix.enable = true;
        sessionVariables.XDG_CONFIG_DIRS = [ "$HOME/.config/kdedefaults" ];
        
        # effectively `qt.enable` and style/platformTheme
        variables = {
          QT_QPA_PLATFORMTHEME = "kde";
          QT_STYLE_OVERRIDE = "breeze";
        };
        profileRelativeSessionVariables = 
          {
            QT_PLUGIN_PATH = map(qt: "/${qt.qtbase.qtPluginPrefix}") [ pkgs.qt6 ];
            QML2_IMPORT_PATH = map(qt: "/${qt.qtbase.qtQmlPrefix}") [ pkgs.qt6 ];
          };
        systemPackages =
          let
            kdepackages =
              (builtins.attrValues {
                inherit (kdePackages)
                  # "required packages"
                  qtwayland
                  qtsvg

                  # Frameworks with globally loadable bits
                  frameworkintegration# provides Qt plugin
                  kauth# provides helper service
                  kcoreaddons# provides extra mime type info
                  kded# provides helper service
                  kfilemetadata# provides Qt plugins
                  kguiaddons# provides geo URL handlers
                  kiconthemes# provides Qt plugins
                  kimageformats# provides Qt plugins
                  qtimageformats# provides optional image formats such as .webp and .avif
                  kio# provides helper service + a bunch of other stuff
                  kio-admin# managing files as admin
                  kio-extras# stuff for MTP, AFC, etc
                  kio-fuse # fuse interface for KIO
                  knighttime # night mode switching daemon
                  kpackage# provides kpackagetool tool
                  kservice# provides kbuildsycoca6 tool
                  kunifiedpush # provides a background service and a KCM
                  plasma-activities# provides plasma-activities-cli tool
                  solid# provides solid-hardware6 tool
                  phonon-vlc # provides Phonon plugin

                  # Core Plasma parts
                  kwin
                  kscreen
                  libkscreen
                  kscreenlocker
                  kactivitymanagerd
                  kde-cli-tools
                  kglobalacceld# keyboard shortcut daemon
                  kwrited # wall message proxy, not to be confused with kwrite
                  baloo # system indexer
                  milou # search engine atop baloo
                  kdegraphics-thumbnailers# pdf etc thumbnailer
                  polkit-kde-agent-1# polkit auth ui
                  plasma-desktop
                  plasma-workspace
                  kde-inotify-survey # warns the user on low inotifywatch limits

                  # Application integration
                  libplasma# provides Kirigami platform theme
                  plasma-integration# provides Qt platform theme
                  kde-gtk-config # syncs KDE settings to GTK

                  # Artwork + themes
                  breeze
                  breeze-icons
                  breeze-gtk
                  ocean-sound-theme
                  qqc2-breeze-style #https://invent.kde.org/frameworks/qqc2-desktop-styl
                  qqc2-desktop-style #https://invent.kde.org/frameworks/qqc2-desktop-style

                  # misc Plasma extras
                  kdeplasma-addons

                  # Plasma utilities
                  kmenuedit
                  kinfocenter
                  plasma-systemmonitor
                  ksystemstats
                  libksysguard
                  systemsettings
                  kcmutils

                  # "optional packages"
                  aurorae
                  plasma-browser-integration
                  plasma-workspace-wallpapers
                  konsole
                  ark
                  elisa
                  gwenview
                  okular
                  kate
                  ktexteditor # provides elevated actions for kate
                  khelpcenter
                  dolphin
                  baloo-widgets # baloo information in Dolphin
                  dolphin-plugins
                  spectacle
                  ffmpegthumbs
                  krdp
                  kconfig# required for xdg-terminal from xdg-utils
                  qtbase# for qtpaths which is required for xdg-mime from xdg-utils
                  # touch keyboard
                  plasma-keyboard
                  qtvirtualkeyboard # used by plasma-keyboard KCM

                  # experimental(?) Union theme
                  union
                  ;
              })
              ++ [
                  pkgs.hicolor-icon-theme # fallback icons
                  pkgs.xdg-user-dirs # recommended upstream
                  (lib.getBin kdePackages.qttools) # Expose qdbus in PATH
              ]
              ++ lib.optionals config.networking.networkmanager.enable [
                kdePackages.qrca
                kdePackages.plasma-nm
              ]
              ++ lib.optionals config.hardware.bluetooth.enable [
                kdePackages.bluedevil
                kdePackages.bluez-qt
              ]
              ++ lib.optional config.hardware.sensor.iio.enable kdePackages.qtsensors
              ++ lib.optional config.services.fwupd.enable kdePackages.discover
              ++ lib.optional (config.services.pulseaudio.enable || config.services.pipewire.pulse.enable) kdePackages.plasma-pa
              ++ lib.optional config.powerManagement.enable kdePackages.powerdevil
              ++ lib.optional config.services.samba.enable kdePackages.kdenetwork-filesharing
              ++ lib.optional config.services.printing.enable kdePackages.print-manager
              ++ lib.optional config.hardware.sane.enable kdePackages.skanpage
              ++ lib.optional config.services.colord.enable kdePackages.colord-kde
              ++ lib.optional config.services.hardware.bolt.enable kdePackages.plasma-thunderbolt
              ++ lib.optional config.services.flatpak.enable kdePackages.flatpak-kcm;
          in
          utils.removePackagesByName kdepackages cfg.excludePackages;
          };
      xdg.portal = {
        enable = true;
        extraPortals = [
          kdePackages.xdg-desktop-portal-kde
        ];
        configPackages = [ kdePackages.plasma-workspace ];
      };
      programs = {
        xwayland.enable = true;
        gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
        ssh.askPassword = "${kdePackages.ksshaskpass.out}/bin/ksshaskpass";
      };
      services = {
        power-profiles-daemon.enable = true;
        pipewire.enable = true;
        displayManager = {
          sessionPackages = [ kdePackages.plasma-workspace.sessions ];
          defaultSession = "plasma";
        };
        udev.packages = [
          pkgs.libmtp.out
          pkgs.media-player-info
        ];
        accounts-daemon.enable = true;
        udisks2.enable = true;
        upower.enable = config.powerManagement.enable;
        libinput.enable = true;
      };
      security = {
        pam.services = {
          kde = {
            allowNullPassword = true;
            fprintAuth = false;
            p11Auth = false;
          };
          kde-fingerprint = lib.mkIf config.services.fprintd.enable {
            fprintAuth = true;
            p11Auth = false;
          };
        };
        wrappers.kwin_wayland = {
          owner = "root";
          group = "root";
          capabilities = "cap_sys_nice+ep";
          source = "${lib.getBin kdePackages.kwin}/bin/kwin_wayland";
        };
      };
    })
    (lib.mkIf cfg.kwallet.enable {
      xdg.portal.extraPortals = [ kdePackages.kwallet ];
      security.pam.services = {
        login.kwallet = {
          enable = true;
          package = kdePackages.kwallet-pam;
        };
        kde.kwallet = {
          enable = true;
          package = kdePackages.kwallet-pam;
        };
        plasmalogin-autologin.rules.auth = lib.mkIf cfg.kwallet.luks {
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
      environment.systemPackages = [
        kdePackages.kwallet
        kdePackages.kwallet-pam
      ] ++ lib.optional cfg.kwallet.manager kdePackages.kwalletmanager;

      systemd.services.plasmalogin.serviceConfig.KeyringMode = "inherit";
    })
    (lib.mkIf cfg.drkonqi {
      systemd = {
        services."drkonqi-coredump-processor@".wantedBy = [ "systemd-coredump@.service" ];
        packages = [ kdePackages.drkonqi ];
      };
      environment.pathsToLink = [ "/libexec" ];
    })

  ];
}
