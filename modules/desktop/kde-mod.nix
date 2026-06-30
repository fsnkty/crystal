{
  config,
  modulesPath,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.desktopManager.plasma6;

  inherit (pkgs) kdePackages;
  inherit (lib)
    getBin
    literalExpression
    mkDefault
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    mkRenamedOptionModule
    optional
    optionals
    types
    ;
in
{
  options = {
    services.desktopManager.plasma6 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the Plasma 6 (KDE 6) desktop environment.";
      };

      themes = {
        breeze.enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Breeze theming (window decorations, plasma style, icons, sounds etc).";
        };
        gtk = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable KDE to manage GTK themes and settings through dconf.";
          };
          setBreeze = mkOption {
            type = types.bool;
            default = true;
            description = "Include and set the GTK theme to the breeze theme defaults.";
          };
        };
      };

      services = {
        drkonqi.enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable the kde crash handling, including notificatons and GUI.";
        };
        plasma-browser-integration.enable = mkOption {
          type = types.bool;
          default = true;
          description = "Include and prompt installation of the plasma browser integration extension, applets and services.";
        };
        kwallet = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable the KDE secrets management services and GUI manager.";
          };
          unlock-with-luks = mkOption {
            type = types.bool;
            default = false;
            description = "Enable KWallet to be automatically unlocked when luks is used and unlocked.";
          };
        };
        rebuild-cache-service = mkOption {
          type = types.bool;
          default = true;
          description = ''
            rebuilds the ksycoca6 cache on system activation and graphical target start.
            This is a workaround to be a incompatibility with NixOS and how ksycoca6 chooses to invalidate cache.
            You can follow the issue here, https://github.com/NixOS/nixpkgs/issues/292632.
          '';
        };
      };

      enableQt5Integration = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Qt 5 integration (theming, etc). Disable for a pure Qt 6 system.";
      };

      notoPackage = mkPackageOption pkgs "Noto fonts - used for UI by default" {
        default = [ "noto-fonts" ];
        example = "noto-fonts-lgc-plus";
      };
    };

    environment.plasma6 = {
      excludePackages = mkOption {
        description = "List of default packages to exclude from the configuration";
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression "[ pkgs.kdePackages.elisa ]";
      };
      # FIXME: warn the user effectively about the potential danger of this option
      excludeRequiredPackages = mkOption {
        description = ''
          WARNING: although some packages here can be safely removed, many will make the desktop fundamentally unuseable if removed
          and or quitely and subtley break many different features. ensure you understand what you are excluding.
          removal of many of these packages after having previously included them may make for invalid user config and or state which could both quitely break features or outright break the desktop.

          List of required packages to exclude from the configuration.
        '';
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression "[ pkgs.kdePackages.kde-inotify-survey ]";
      };
      ModuleRestrictions = mkOption {
        description = ''
          hide kde systemsettings entrys when not relavent to the systems configuration
          e.g.. hiding bluetooth settings when hardware.bluetooth.enable = false;
          or hiding user settings when users.mutableUsers = false;

          disabling this will rely on systemsettings to guess at whats available, this may show some settings which will silently fail.
        '';
        type = types.bool;
        default = true;
      };
    };
  };

  imports = [
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "plasma6" "enable" ]
      [ "services" "desktopManager" "plasma6" "enable" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "plasma6" "enableQt5Integration" ]
      [ "services" "desktopManager" "plasma6" "enableQt5Integration" ]
    )
    (mkRenamedOptionModule
      [ "services" "xserver" "desktopManager" "plasma6" "notoPackage" ]
      [ "services" "desktopManager" "plasma6" "notoPackage" ]
    )
  ];

  config = mkMerge [
    (mkIf cfg.enable {
      nixpkgs.overlays = [
      (final: prev: {
        kdePackages = prev.kdePackages.overrideScope (
          kdeFinal: kdePrev: {
            # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
            # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
            plasma-workspace =
              let
                # the package we want to override
                basePkg = kdePrev.plasma-workspace;
                # a helper package that merges all the XDG_DATA_DIRS into a single directory
                xdgdataPkg = final.stdenv.mkDerivation {
                  name = "${basePkg.name}-xdgdata";
                  buildInputs = [ basePkg ];
                  dontUnpack = true;
                  dontFixup = true;
                  dontWrapQtApps = true;
                  installPhase = ''
                    mkdir -p $out/share
                    ( IFS=:
                      for DIR in $XDG_DATA_DIRS; do
                        if [[ -d "$DIR" ]]; then
                          ${prev.lib.getExe prev.lndir} -silent "$DIR" $out
                        fi
                      done
                    )
                  '';
                };
                # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
                # script and instead inject the path of the above helper package
                derivedPkg = basePkg.overrideAttrs {
                  preFixup = ''
                    for index in "''${!qtWrapperArgs[@]}"; do
                      if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                        unset -v "qtWrapperArgs[$((index+0))]"
                        unset -v "qtWrapperArgs[$((index+1))]"
                        unset -v "qtWrapperArgs[$((index+2))]"
                        unset -v "qtWrapperArgs[$((index+3))]"
                      fi
                    done
                    qtWrapperArgs=("''${qtWrapperArgs[@]}")
                    qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                    qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
                  '';
                };
              in
              derivedPkg;
          }
        );
      })
    ];
      qt.enable = true;
      programs.xwayland.enable = true;
      environment.systemPackages =
        let
          requiredPackages =
            (builtins.attrValues {
              inherit (kdePackages)
                qtwayland # Hack? To make everything run on Wayland
                qtsvg # Needed to render SVG icons

                # Frameworks with globally loadable bits
                frameworkintegration # provides Qt plugin
                kauth # provides helper service
                kcoreaddons # provides extra mime type info
                kded # provides helper service
                kfilemetadata # provides Qt plugins
                kguiaddons # provides geo URL handlers
                kiconthemes # provides Qt plugins
                kimageformats # provides Qt plugins
                qtimageformats # provides optional image formats such as .webp and .avif
                kio # provides helper service + a bunch of other stuff
                kio-admin # managing files as admin
                kio-extras # stuff for MTP, AFC, etc
                kio-fuse # fuse interface for KIO
                knighttime # night mode switching daemon
                kpackage # provides kpackagetool tool
                kservice # provides kbuildsycoca6 tool
                kunifiedpush # provides a background service and a KCM
                plasma-activities # provides plasma-activities-cli tool
                solid # provides solid-hardware6 tool
                phonon-vlc # provides Phonon plugin

                # Core Plasma parts
                kwin
                kscreen
                libkscreen
                kscreenlocker
                kactivitymanagerd
                kde-cli-tools
                kglobalacceld # keyboard shortcut daemon
                kwrited # wall message proxy, not to be confused with kwrite
                baloo # system indexer
                milou # search engine atop baloo
                kdegraphics-thumbnailers # pdf etc thumbnailer
                polkit-kde-agent-1 # polkit auth ui
                plasma-desktop
                plasma-workspace
                kde-inotify-survey # warns the user on low inotifywatch limits

                # Application integration
                libplasma # provides Kirigami platform theme
                plasma-integration # provides Qt platform theme
                kde-gtk-config # syncs KDE settings to GTK

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
                ;
            })
            ++ [
              pkgs.hicolor-icon-theme # fallback icons
              pkgs.xdg-user-dirs # recommended upstream
            ];
          optionalPackages =
            (builtins.attrValues {
              inherit (kdePackages)
                aurorae
                plasma-workspace-wallpapers
                konsole
                kwin-x11
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
                kconfig # required for xdg-terminal from xdg-utils
                qtbase # for qtpaths which is required for xdg-mime from xdg-utils
                # touch keyboard
                plasma-keyboard
                qtvirtualkeyboard # used by plasma-keyboard KCM
                ;
            })
            ++ [ (getBin kdePackages.qttools) ] # Expose qdbus in PATH
            ++ optional config.networking.networkmanager.enable kdePackages.qrca
            ++ optionals config.hardware.sensor.iio.enable [
              # This is required for autorotation in Plasma 6
              kdePackages.qtsensors
            ]
            ++ optionals (config.services.flatpak.enable || config.services.fwupd.enable) [
              # Since PackageKit Nix support is not there yet,
              # only install discover if flatpak or fwupd is enabled.
              kdePackages.discover
            ];
        in
        utils.removePackagesByName requiredPackages config.environment.plasma6.excludeRequiredPackages
        ++ utils.removePackagesByName optionalPackages config.environment.plasma6.excludePackages
        ++ optionals config.services.desktopManager.plasma6.enableQt5Integration [
          kdePackages.breeze.qt5
          kdePackages.plasma-integration.qt5
          kdePackages.kwayland-integration
          (
            # Only symlink the KIO plugins, so we don't accidentally pull any services
            # like KCMs or kcookiejar
            let
              kioPluginPath = "${pkgs.libsForQt5.qtbase.qtPluginPrefix}/kf5/kio";
              inherit (pkgs.libsForQt5.__internalKF5) kio;
            in
            pkgs.runCommand "kio5-plugins-only" { } ''
              mkdir -p $out/${kioPluginPath}
              ln -s ${kio}/${kioPluginPath}/* $out/${kioPluginPath}
            ''
          )
          kdePackages.kio-extras-kf5
        ]
        # Optional and hardware support features
        ++ optionals config.hardware.bluetooth.enable [
          kdePackages.bluedevil
          kdePackages.bluez-qt
          pkgs.openobex
          pkgs.obexftp
        ]
        ++ optional config.networking.networkmanager.enable kdePackages.plasma-nm
        ++ optional config.services.pulseaudio.enable kdePackages.plasma-pa
        ++ optional config.services.pipewire.pulse.enable kdePackages.plasma-pa
        ++ optional config.powerManagement.enable kdePackages.powerdevil
        ++ optional config.services.printing.enable kdePackages.print-manager
        ++ optional config.hardware.sane.enable kdePackages.skanpage
        ++ optional config.services.colord.enable kdePackages.colord-kde
        ++ optional config.services.hardware.bolt.enable kdePackages.plasma-thunderbolt
        ++ optional config.services.samba.enable kdePackages.kdenetwork-filesharing
        ++ optional config.services.xserver.wacom.enable kdePackages.wacomtablet
        ++ optional config.services.flatpak.enable kdePackages.flatpak-kcm;

      # FIXME: modules should link subdirs of `/share` rather than relying on this
      environment.pathsToLink = [ "/share" ];

      environment.etc."X11/xkb".source = config.services.xserver.xkb.dir;

      # Add ~/.config/kdedefaults to XDG_CONFIG_DIRS for shells, since Plasma sets that.
      # FIXME: maybe we should append to XDG_CONFIG_DIRS in /etc/set-environment instead?
      environment.sessionVariables.XDG_CONFIG_DIRS = [ "$HOME/.config/kdedefaults" ];

      # Needed for things that depend on other store.kde.org packages to install correctly,
      # notably Plasma look-and-feel packages (a.k.a. Global Themes)
      #
      # FIXME: this is annoyingly impure and should really be fixed at source level somehow,
      # but kpackage is a library so we can't just wrap the one thing invoking it and be done.
      # This also means things won't work for people not on Plasma, but at least this way it
      # works for SOME people.
      environment.sessionVariables.KPACKAGE_DEP_RESOLVERS_PATH = "${kdePackages.frameworkintegration.out}/libexec/kf6/kpackagehandlers";

      fonts.packages = [
        cfg.notoPackage
        pkgs.hack-font
      ];
      fonts.fontconfig.defaultFonts = {
        monospace = [
          "Hack"
          "Noto Sans Mono"
        ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };

      programs.gnupg.agent.pinentryPackage = mkDefault pkgs.pinentry-qt;
      programs.kde-pim.enable = mkDefault true;
      programs.ssh.askPassword = mkDefault "${kdePackages.ksshaskpass.out}/bin/ksshaskpass";

      # Enable helpful DBus services.
      services.accounts-daemon.enable = true;
      # when changing an account picture the accounts-daemon reads a temporary file containing the image which systemsettings5 may place under /tmp
      systemd.services.accounts-daemon.serviceConfig.PrivateTmp = false;

      services.power-profiles-daemon.enable = mkDefault true;
      services.system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);
      programs.fuse.enable = true;
      services.udisks2.enable = true;
      services.upower.enable = config.powerManagement.enable;
      services.libinput.enable = mkDefault true;
      services.geoclue2.enable = mkDefault true;
      services.fwupd.enable = mkDefault true;

      # Extra UDEV rules used by Solid
      services.udev.packages = [
        # libmtp has "bin", "dev", "out" outputs. UDEV rules file is in "out".
        pkgs.libmtp.out
        pkgs.media-player-info
      ];

      xdg.icons.enable = true;

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [
        kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
      ];
      xdg.portal.configPackages = mkDefault [ kdePackages.plasma-workspace ];
      services.pipewire.enable = mkDefault true;

      # Enable screen reader by default
      services.orca.enable = mkDefault true;

      services.displayManager = {
        sessionPackages = [ kdePackages.plasma-workspace.sessions ];
        defaultSession = mkDefault "plasma";
      };
      services.displayManager.sddm = {
        package = kdePackages.sddm;
        theme = mkDefault "breeze";
        wayland = mkDefault {
          enable = true;
          compositor = "kwin";
        };
        extraPackages = builtins.attrValues {
          inherit (kdePackages)
            breeze-icons
            kirigami
            libplasma
            plasma5support
            qtsvg
            qtvirtualkeyboard
            ;
        };
      };

      security.pam.services = {
        kde = {
          allowNullPassword = true;
          # "kde" must not have fingerprint authentication otherwise it can block password login.
          # See https://github.com/NixOS/nixpkgs/issues/239770 and https://invent.kde.org/plasma/kscreenlocker/-/merge_requests/163.
          fprintAuth = false;
          p11Auth = false;
        };
        kde-fingerprint = mkIf config.services.fprintd.enable {
          fprintAuth = true;
          p11Auth = false;
        };
        kde-smartcard = mkIf config.security.pam.p11.enable {
          p11Auth = true;
          fprintAuth = false;
        };
      };

      security.wrappers = {
        kwin_wayland = {
          owner = "root";
          group = "root";
          capabilities = "cap_sys_nice+ep";
          source = "${getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
        };
        # FIXME: this should likely be conditional on having the appropriate hardware
        # however, there is no obvious comprehensive way to check this
        ksystemstats_intel_helper = {
          owner = "root";
          group = "root";
          capabilities = "cap_perfmon+ep";
          source = "${pkgs.kdePackages.ksystemstats}/libexec/ksystemstats_intel_helper";
        };

        ksgrd_network_helper = {
          owner = "root";
          group = "root";
          capabilities = "cap_net_raw+ep";
          source = "${pkgs.kdePackages.libksysguard}/libexec/ksysguard/ksgrd_network_helper";
        };
      };

      # Upstream recommends allowing set-timezone and set-ntp so that the KCM and
      # the automatic timezone logic work without user interruption.
      # However, on NixOS NTP cannot be overwritten via dbus, and timezone
      # can only be set if `time.timeZone` is set to `null`. So, we only allow
      # set-timezone, and we only allow it when the timezone can actually be set.
      security.polkit.extraConfig = mkIf (config.time.timeZone != null) ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.timedate1.set-timezone" && subject.active) {
            return polkit.Result.YES;
          }
        });
      '';

      programs.kdeconnect.package = kdePackages.kdeconnect-kde;
      programs.partition-manager.package = kdePackages.partitionmanager;

    })
    (mkIf cfg.themes.breeze.enable {
      environment.systemPackages = builtins.attrValues {
        inherit (kdePackages)
          breeze
          breeze-icons
          ocean-sound-theme
          qqc2-breeze-style
          qqc2-desktop-style
          ;
      };
      qt = {
        platformTheme = "kde";
        style = "breeze";
      };
      xdg.icons.fallbackCursorThemes = [ "breeze_cursors" ];
    })
    (mkIf cfg.themes.gtk.enable {
      environment.systemPackages = [
        kdePackages.kde-gtk-config
      ]
      ++ optionals cfg.themes.gtk.setBreeze [
        kdePackages.breeze-gtk
      ];
      programs = {
        dconf = {
          enable = true;
          profiles.user.databases = mkIf cfg.themes.gtk.setBreeze [
            {
              settings = {
                "org/gnome/desktop/interface".gtk-theme = "Breeze";
                # FIXME: Some cases when setting dconf settings like above can remove this typically expected behaviour.
                # Ideally this would not be secretly set under this option, But atleast this way it breaks less expected behaviour over all.
                "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
              };
            }
          ];
        };
        # Enable GTK applications to load SVG icons
        gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
      };
    })
    (mkIf cfg.services.drkonqi.enable {
      systemd = {
        packages = [ kdePackages.drkonqi ];
        services."drkonqi-coredump-processor@".wantedBy = [ "systemd-coredump@.service" ];
      };
      environment = {
        systemPackages = [ kdePackages.drkonqi ];
        pathsToLink = [ "/libexec" ];
      };
    })
    (mkIf cfg.services.plasma-browser-integration.enable {
      environment.systemPackages = [ kdePackages.plasma-browser-integration ];
      programs = {
        firefox.nativeMessagingHosts.packages = [ kdePackages.plasma-browser-integration ];
        chromium = {
          enablePlasmaBrowserIntegration = true;
          plasmaBrowserIntegrationPackage = kdePackages.plasma-browser-integration;
        };
      };
    })
    (mkIf cfg.services.kwallet.enable {
      security.pam.services = {
        login.kwallet = {
          enable = true;
          package = kdePackages.kwallet-pam;
        };
        kde.kwallet = {
          enable = true;
          package = kdePackages.kwallet-pam;
        };
      };
      environment.systemPackages = [
        kdePackages.kwallet
        kdePackages.kwallet-pam
        kdePackages.kwalletmanager
      ];
      xdg.portal.extraPortals = [ kdePackages.kwallet ];
    })
    (mkIf cfg.services.kwallet.unlock-with-luks {
      # FIXME: assert boot.initrd.systemd.enable = true
      # or at minimum, warn the user that it is expected to be enabled for this option
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
    })
    (
      let
        activationScript = ''
          # will be rebuilt automatically
          rm -fv "''${XDG_CACHE_HOME:-$HOME/.cache}/ksycoca"*
        '';
      in
      mkIf cfg.services.rebuild-cache-service {
        # FIXME: ugly hack. See #292632 for details.
        system.userActivationScripts.rebuildSycoca = activationScript;
        systemd.user.services.nixos-rebuild-sycoca = {
          description = "Rebuild KDE system configuration cache";
          wantedBy = [ "graphical-session-pre.target" ];
          serviceConfig.Type = "oneshot";
          script = activationScript;
        };
      }
    )
    (mkIf config.environment.plasma6.ModuleRestrictions {
      environment.etc."xdg/kdeglobals".text =
        lib.generators.toINI
          {
            # avoid the generator escaping inner "]["
            mkSectionName = name: name;
          }
          {
            # list from "kcmshell6 --list" as of kcmshell6 6.27.0
            # a form of alert when kcmshell6 updates could help keep track of new/removed entries to this list.
            "KDE Control Module Restrictions][$i" = {
              #kcm_access = # includes some features very deeply intertwined with plasma, unlikely to hide
              #kcm_activities = # unsure of inclusion
              #kcm_animations = # quite deeply intertwined, unlikely to hide
              #kcm_autostart = # unsure, likely a XDG related feature
              kcm_baloofile = builtins.elem kdePackages.baloo config.environment.systemPackages;
              kcm_bluetooth = config.hardware.bluetooth.enable;
              #kcm_clock = # deeply intertwined, unlikely to hide
              #kcm_colors = # deeply intertwined, unlikely to hide
              #kcm_componentchooser = # unsure, likely a XDG related feature
              #kcm_cursortheme = # likely makes sense to hide if a theme is declaritively set in some way
              #kcm_desktoppaths = # xdg-user-dirs related
              #kcm_desktoptheme = # simialr to cursor, likely makes sense to hide in declaritively set
              #kcm_device_automounter = # potentially depends on Solid.
              #kcm_feedback = # likely only makes sense to hide on user preference.
              #kcm_fontinst = # can likely install to user dirs though anything related to system fonts likely silently fails
              #kcm_fonts = # might make sense to hide when config.fonts.* is used.
              #kcm_gamecontroller = # systemsettings already seems to handle this fairly well, may still be useful to hide, though im not sure theres a reliable way to determine the system is setup or a gamecontroller
              #kcm_icons = # similar to cursor and desktop theme
              #kcm_kded = # background service config, likely quite intertwined so unlikely to hide
              #kcm_keyboard = # unlikely to hide, maybe if Solid is not in use? though even then doesnt seem likely.
              #kcm_keys = # deeply intertwined, unlikely to hide.
              #kcm_kscreen = # should likely be set on if kscreen and related is included or not.
              kcm_kwallet5 = config.services.desktopManager.plasma6.services.kwallet.enable;
              # the below could be hidden if kwin has been replaced?
              # not familar enough with the use case of replacing kwin.
              #kcm_kwin_effects =
              #kcm_kwin_scripts =
              #kcm_kwin_virtualdesktops =
              #kcm_kwindecoration =
              #kcm_kwinoptions =
              #kcm_kwinrules =
              #kcm_kwinscreenedges =
              #kcm_kwintabbox =
              #kcm_kwintouchscreen =
              #kcm_kwinxwayland =
              # section end
              #kcm_landingpage = # user preference
              #kcm_lookandfeel = # likely not reasonable to hide
              kcm_mobile_power = config.services.power-profiles-daemon.enable;
              #kcm_mouse = # maybe Solid dep
              #kcm_netpref = # systemsettings seemingly alredy does an ok job of hiding what it cannot affect, potentiall useful to hide for some use cases.
              #kcm_nightlight = # may depend on knighttime
              kcm_nighttime = builtins.elem kdePackages.knighttime config.environment.systemPackages;
              #kcm_notifications = # deps possible removal
              #kcm_plasmalogin = # plasma-login-manager?
              #kcm_plasmasearch = # baloo? milou? krunner?
              kcm_powerdevilprofilesconfig = config.services.power-profiles-daemon.enable;
              #kcm_proxy = # systemsettings seemingly handles this well as is
              kcm_pulseaudio = config.services.pulseaudio.enable || config.services.pipewire.pulse.enable;
              #kcm_qtquicksettings = # user pref
              #kcm_recentFIles = # potential xdg dep
              #kcm_regionandlang = # this and the polkit extraConfig related on if the timezone isnt declaritively set
              #kcm_screenlocker = # includes relavent deps
              #kcm_smserver = # unlikely to hide
              #kcm_solid_actions = # device on connect actions, hide if solid isnt included
              #kcm_soundtheme = # like other theme entrys
              #kcm_splashscreen = # like other theme entrys
              #kcm_style = # like other theme entrys
              #kcm_tablet = # seemingly handles this fine as is
              #kcm_touchpad = # seeemingly handles this fine as is
              #kcm_touchscreen = # seemingly handles this fine as is
              kcm_users = config.users.mutableUsers;
              #kcm_virtualkeyboard = # depdend on relavent deps being included
              #kcm_wallpaper = # unlikely to hide
              #kcm_webshortcuts = # likely xdg dep
              #kcm_workspace = # unlikely to hide
              #kcmspellchecking = # maybe dep on dictionaries being available
            };
          };
    })
  ];
}
