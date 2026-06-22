# a reimplamentation of nixpkgs plasma6.nix as of here
# https://github.com/NixOS/nixpkgs/blob/bb38195945cf64396b4997e3c84703b519be86b0/nixos/modules/services/desktop-managers/plasma6.nix

# breaking
# qt5 ommited

# wishful
# remove plastik, windows 9x and fusion theme options.
# unfortunately not realistic as they seem to be deeply intertwined in QT or Kwin, removal would require rebuilds.
# not so bad in the case of kwin, but for QT would cascase heavily, very sad.
# fix https://discourse.nixos.org/t/manage-printers-in-applications-list-while-cups-disabled/55909

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.crystal.desktop.kde;
  kdePkgs = pkgs.kdePackages;
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkMerge
    optional
    optionals
    getBin
    ;
in
{
  options.crystal.desktop.kde = {
    enable = mkEnableOption "";
    breeze.enable = mkEnableOption "set all themes to breeze";
    gtk = {
      enable = mkEnableOption "KDe management of GTK";
      setBreeze = mkEnableOption "sets gtk settings to breeze themes";
    };
    drkonqi.enable = mkEnableOption "a GUI crash handler";
    plasma-browser-integration.enable = mkEnableOption "";
    kwallet = {
      enable = mkEnableOption "";
      unlock-with-luks = mkEnableOption "";
    };
    rebuild-cache-service = mkEnableOption "rebuild the application cache on graphical session start.";
  };
  config = mkMerge [
    (mkIf cfg.enable {
      qt.enable = true;
      programs = {
        xwayland.enable = true;
        # use appropreate services/packages when using plasma
        gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
        ssh.askPassword = "${kdePkgs.ksshaskpass.out}/bin/ksshaskpass";
        kdeconnect.package = kdePkgs.kdeconnect-kde;
        partition-manager.package = kdePkgs.partitionmanager;
      };
      xdg.portal = {
        enable = true;
        extraPortals = [ kdePkgs.xdg-desktop-portal-kde ];
        configPackages = [ kdePkgs.plasma-workspace ];
      };
      services = {
        displayManager = {
          sessionPackages = [ kdePkgs.plasma-workspace.sessions ];
          defaultSession = "plasma";
        };
        displayManager.sddm = {
          package = kdePkgs.sddm;
          theme = mkDefault "breeze";
          wayland = mkDefault {
            enable = true;
            compositor = "kwin";
          };
          extraPackages = (
            builtins.attrValues {
              inherit (kdePkgs)
                breeze-icons
                kirigami
                libplasma
                plasma5support
                qtsvg
                qtvirtualkeyboard
                ;
            }
          );
        };
        # "Enable helpful DBus services."
        power-profiles-daemon.enable = mkDefault true;
        system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);
        udisks2.enable = true;
        upower.enable = config.powerManagement.enable;
        libinput.enable = mkDefault true;
        geoclue2.enable = mkDefault true;
        fwupd.enable = mkDefault true;
        # Extra UDEV rules used by Solid
        udev.packages = [
          # libmtp has "bin", "dev", "out" outputs. UDEV rules file is in "out".
          pkgs.libmtp.out
          pkgs.media-player-info
        ];
      };
      environment = {
        # Needed for things that depend on other store.kde.org packages to install correctly,
        # notably Plasma look-and-feel packages (a.k.a. Global Themes)
        #
        # FIXME: this is annoyingly impure and should really be fixed at source level somehow,
        # but kpackage is a library so we can't just wrap the one thing invoking it and be done.
        # This also means things won't work for people not on Plasma, but at least this way it
        # works for SOME people.
        sessionVariables.KPACKAGE_DEP_RESOLVERS_PATH = "${kdePkgs.frameworkintegration.out}/libexec/kf6/kpackagehandlers";
        # FIXME: modules should link subdirs of `/share` rather than relying on this
        pathsToLink = [ "/share" ];
        etc."X11/xkb".source = config.services.xserver.xkb.dir;
        # packages
        systemPackages =
          (builtins.attrValues {
            inherit (kdePkgs)
              # "requiredPackages"
              qtwayland # "Hack? To make everything run on Wayland"
              qtsvg # "Needed to render SVG icons"

              # "Frameworks with globally loadable bits"
              frameworkintegration # "provides Qt plugin" seems to be for QT apps to integrate with KDE more
              kauth # "provides helper service" privilege elevation
              kcoreaddons # "provides extra mime type info" seemingly does various file and text manip
              kded # "provides helper service" handles various background helper services, "KDED stands for KDE Daemon"
              kfilemetadata # "provides Qt plugins"
              kguiaddons # "provides geo URL handlers"
              kiconthemes # "provides Qt plugins"
              kimageformats # "provides Qt plugins"
              qtimageformats # "provides optional image formats such as .webp and .avif"
              kio # "helper service + a bunch of other stuff"
              kio-extras # desktop:/
              kio-admin # "managing files as admin"
              kpackage # "provides kpackage tool
              kservice # "provides kbuildsyscoco6 tool"
              plasma-activities # "provides plasma-activities-cli tool"
              solid # "provides solid-hardware6 tool" various hardware reading capabilities

              # "Core Plasma parts"
              kwin # compositor / window management
              kscreen # screen management
              kscreenlocker
              kactivitymanagerd
              kglobalacceld # "keyboard shorecut daemon"
              kdegraphics-thumbnailers # "pdf etc thumbnailer"
              polkit-kde-agent-1 # "polkit auth ui"
              plasma-desktop
              plasma-workspace
              kde-inotify-survey # "warns the user on low inotifywatch limits" inotify is related to filesystem events.

              # "Application integration"
              libplasma # "provides kirigami platform theme"
              plasma-integration # "provides Qt platform theme"

              # "Artwork + themes"
              breeze
              breeze-icons
              ocean-sound-theme
              # same theme, different framework?
              #qqc2-breeze-style
              #qqc2-desktop-style

              systemsettings # settings app
              kcmutils # utilities for modules

              # "optional Packages"
              ark # gui 7zip? maybe useful ig
              gwenview # photo viewer
              dolphin # file manager
              spectacle # screenshots
              ffmpegthumbs # makes thumbnails of videos, prob just a dolphin dep
              kconfig # required for xdg-terminal from xdg-utils
              qtbase # for qtpaths which is required for xdg-mime from xdg-utils
              ;
          })
          ++ optionals config.hardware.bluetooth.enable [
            kdePkgs.bluedevil # applet & settings
            kdePkgs.bluez-qt # Bluez5 DBus API QT wrapper
            pkgs.openobex # file sharing
            pkgs.obexftp # file access, typically smartphones
          ]
          ++ optional config.networking.networkmanager.enable kdePkgs.plasma-nm # network management integration
          ++ optional config.services.pulseaudio.enable kdePkgs.plasma-pa # pulse audio integration
          ++ optional config.services.pipewire.pulse.enable kdePkgs.plasma-pa # pulse audio integration
          ++ optional config.services.printing.enable kdePkgs.print-manager # printer management GUI app
          ++ optional config.services.colord.enable kdePkgs.colord-kde # colord?
          ++ optional config.services.hardware.bolt.enable kdePkgs.plasma-thunderbolt # thunderbolt, applet? settings?
          ++ optional config.services.samba.enable kdePkgs.kdenetwork-filesharing # file sharing settings and applet
          ++ optional config.services.xserver.wacom.enable kdePkgs.wacomtablet # wacom tablet support
          ++ optional config.services.flatpak.enable kdePkgs.flatpak-kcm # flatpak integration
          ++ optional config.powerManagement.enable kdePkgs.powerdevil # powerManagement applet? settings?
          ++ optional config.hardware.sane.enable kdePkgs.skanpage; # unsure.
      };
      security = {
        pam.services = {
          kde = {
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
        wrappers = {
          kwin_wayland = {
            owner = "root";
            group = "root";
            capabilities = "cap_sys_nice+ep";
            source = "${getBin kdePkgs.kwin}/bin/kwin_wayland";
          };
          # FIXME: ideally this would be conditional on having relavent hardware, though theres no obvious way to determine this.
          ksystemstats_intel_helper = {
            owner = "root";
            group = "root";
            capabilities = "cap_perfmon+ep";
            source = "${kdePkgs.ksystemstats}/libexec/ksystemstats_intel_helper";
          };
          # FIXME: should be made conditional on if related system monitoring tools are included, though theres no obvious way to determine this.
          ksgrd_network_helper = {
            owner = "root";
            group = "root";
            capabilities = "cap_net_raw+ep";
            source = "${kdePkgs.libksysguard}/libexec/ksysguard/ksgrd_network_helper";
          };
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
    })
    (mkIf cfg.breeze.enable {
      qt = {
        platformTheme = "kde";
        style = "breeze";
      };
      xdg.icons = {
        enable = true;
        fallbackCursorThemes = [ "breeze_cursors" ];
      };
    })
    (mkIf cfg.gtk.enable {
      environment.systemPackages = [
        kdePkgs.kde-gtk-config
      ]
      ++ optionals cfg.gtk.setBreeze [ kdePkgs.breeze-gtk ];
      programs = {
        dconf = {
          enable = true;
          profiles.user.databases = mkIf cfg.gtk.setBreeze [
            {
              settings = {
                "org/gnome/desktop/interface".gtk-theme = "Breeze";
                "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
              };
            }
          ];
        };
        gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
      };
    })
    (mkIf cfg.drkonqi.enable {
      systemd = {
        packages = [ kdePkgs.drkonqi ];
        services."drkonqi-coredump-processor@".wantedBy = [ "systemd-coredump@.service" ];
      };
      environment = {
        systemPackages = [ kdePkgs.drkonqi ];
        pathsToLink = [ "/libexec" ];
      };
    })
    # FIXME: ugly hack. See #292632 for details.
    (
      let
        activationScript = ''
          # will be rebuilt automatically
          rm -fv "''${XDG_CACHE_HOME:-$HOME/.cache}/ksycoca"*
        '';
      in
      mkIf cfg.rebuild-cache-service {
        system.userActivationScripts.rebuildSycoca = activationScript;
        systemd.user.services.nixos-rebuild-sycoca = {
          description = "Rebuild KDE system configuration cache";
          wantedBy = [ "graphical-session-pre.target" ];
          serviceConfig.Type = "oneshot";
          script = activationScript;
        };
      }
    )
    (mkIf cfg.kwallet.enable {
      security.pam.services = {
        login.kwallet = {
          enable = true;
          package = kdePkgs.kwallet-pam;
        };
        kde.kwallet = {
          enable = true;
          package = kdePkgs.kwallet-pam;
        };
      };
      environment.systemPackages = [
        kdePkgs.kwallet
        kdePkgs.kwallet-pam
      ];
      xdg.portal.extraPortals = [ kdePkgs.kwallet ];
    })
    (mkIf cfg.kwallet.unlock-with-luks {
      # FIXME: assert boot.initrd.systemd.enable = true
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
    (mkIf cfg.plasma-browser-integration.enable {
      environment.systemPackages = [ kdePkgs.plasma-browser-integration ];
      programs = {
        firefox.nativeMessagingHosts.packages = [ kdePkgs.plasma-browser-integration ];
        chromium = {
          enablePlasmaBrowserIntegration = true;
          plasmaBrowserIntegrationPackage = kdePkgs.plasma-browser-integration;
        };
      };
    })
    (mkIf cfg.qt5.enable {
      environment.systemPackages = [
        kdePkgs.breeze.qt5
        kdePkgs.plasma-integration.qt5
        kdePkgs.kwayland-integration
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
        kdePkgs.kio-extras-kf5
      ];
    })
  ];
}
